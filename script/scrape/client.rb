#require 'scrape'

module Scrape

  # The base(parent) class of scraping classes.
  class Client
    include Scrape
    attr_accessor :logger, :limit, :pid_debug, :sleep_debug
    ROOT_URL = ''

    # Initializes a new Client object
    # @param limit [Integer]
    # @param logger [Logger]
    # @return [Scrape::Client]
    def initialize(logger=nil, limit=1)
      self.limit = limit
      # Generate an instance of a default logger
      if logger.nil?
        self.logger = Logger.new('log/scrape.log')
      else
        self.logger = logger
      end
      self.logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    end


    # Scrape images from websites which has api. The latter two params are used for testing.
    # @param module_type [String]
    # @param [Integer] min
    # @param logger [Logger] logger instance to output logs.
    # @param [Boolean] whether it's called for debug or not
    # @param [Boolean] whether it's called for debug or not
    def scrape_target_words(module_type, interval=60)
      # Raise an exception if interval is too short
      if interval < 15
        raise Exception.new('the interval argument must be more than 10!')
        return
      end

      reserved_time = 10
      local_interval = (interval-reserved_time) / (TargetWord.count*1.0)
      @logger.info '--------------------------------------------------'
      @logger.info "Start extracting from #{self.class::ROOT_URL}"
      @logger.info "interval=#{interval} local_interval=#{local_interval}"

      # Prevent duplicate running, using PID file
      detect_multiple_running(false)


      # Scrape images tag by tag with text tag search API
      count = 0
      target_word = TargetWord.first

      while (count < TargetWord.count) do
        begin
          # Actually start crawling with target_word
          crawl_target_word(target_word)
        rescue => e
          # Writes logs and send an email manually
          @logger.info e.inspect
          @logger.info e.backtrace
          logger.error "Scraping from #{self.class::ROOT_URL} has failed!"
          send_error_mail(e, module_type, target_word) if Rails.env.production?
        end

        begin
          # Using next method, get the second youngest record next to target_word record
          target_word = target_word.next
          count+=1

          # Sleep for calculated time
          # Convert minutes to seconds
          sleep_time = local_interval*60
          logger.info "Sleeping #{local_interval} minutes."
          if count == TargetWord.count
            logger.info "Reached the last TargetWord record. Exiting..."
            break
          else
            sleep(sleep_time) unless @sleep_debug
          end
        rescue Exception => e
          puts e.inspect
          puts e.backtrace
        end

      end
      @logger.info '--------------------------------------------------'
    end


    # Crawl images with a TargetWord reccord.
    # @param target_word [TargetWord] A TargetWord record to crawl with.
    def crawl_target_word(target_word)
      # Do an API request based on paramters, and get the result
      #if (not target_word.name.nil?) and (not target_word.name.empty?)

      # Execute with default parameters
      result = scrape_using_api(target_word)
      @logger.info Scrape.get_result_string(result)
      puts result.inspect

      target_word.crawl_count += 1
      target_word.save!
    end


    # Scrapes images by APIs. Used in child classes through overriding.
    # @param target_word [TargetWord] A TargetWord object to scrape
    # @return [Hash] The result of scraping
    def scrape_using_api(target_word)
      { scraped: 0, duplicates: 0, skipped: 0, avg_time: 0 }
    end


    # Prevent multiple running of the process based on PID file.
    # See 'pidfile' gem
    # @param [Boolean] Whether it uses PidFile or not
    # @param [Boolean] Whether it writes debug outputs or not
    def detect_multiple_running(debug=false)
      unless @pid_debug
        # Finish the process if there is already a PidFile
        if PidFile.running?
          @logger.info 'Another process is already runnnig. Exit.'
          exit
        end

        # If there aren't any PidFiles, create one and prevent any new processes from running
        pid_hash = {
          pidfile: "#{self.class.name}.pid",
          piddir: "#{Rails.root}/tmp/pids"
        }
        p = PidFile.new(pid_hash)

        # As default, PidFiles are created under /tmp directory.
        @logger.debug 'PidFile DEBUG:'
        @logger.debug p.pidfile
        @logger.debug p.piddir
        @logger.debug p.pid
        @logger.debug p.pidpath
      end
    end

    # Print debugging info
    def _print
      require 'objspace'
      @logger.debug "count_objects:#{ObjectSpace.count_objects}" #=> {:TOTAL=>55298, :FREE=>10289, :T_OBJECT=>3371, ...}
      @logger.debug "memsize_of_all:#{ObjectSpace.memsize_of_all}" # Display all memory usage in bytes
    end

    # Returns true if the tags contain adult words
    # See details at: https://github.com/tjackiw/obscenity
    # @param tags [ActiveRecord::Associations::CollectionProxy]
    # @return [Boolean] Contains adult words or not
    def self.is_banned(tags)
      tags.each do |tag|
        return true if Obscenity.profane?(tag.name)
      end
      false
    end

    # Returns true if the tags contain photo related words, like 'cosplay' and 'figure'
    # See details at: https://github.com/tjackiw/obscenity
    # @param tags [ActiveRecord::Associations::CollectionProxy]
    # @return [Boolean] Contains adult words or not
    def self.is_photo(tags)
      tags.each do |tag|
        return true if Obscenity.profane_another?(tag.name)
      end
      false
    end


    # Checks if the given image is irrelavant or not
    # @param image [Image] An Image object to examine
    # @return [Boolean] Contains adult words or not
    def self.check_banned(image)
      return true if Obscenity.profane?(image.title)
      return true if Obscenity.profane?(image.caption)

      if (not image.tags.nil?) and (not image.tags.empty?)
        return true if self.is_banned(image.tags)
      end
      false
    end

    # Checks if the given image is irrelavant or not
    # @param image [Image] An Image object to examine
    # @return [Boolean] Contains adult words or not
    def self.check_photo(image)
      return true if Obscenity.profane_another?(image.title)
      return true if Obscenity.profane_another?(image.caption)

      if (not image.tags.nil?) and (not image.tags.empty?)
        return true if self.is_photo(image.tags)
      end
      false
    end


    # Create new image instanace and save it to the database.
    # @param [Hash] A hash that represents attributes of Image
    # @param [Array] An Array of string that represents text tags
    # @param [Boolean] Whether it carry outs validation or not
    # @param [Boolean] Whether image file is large or not
    # @param [Boolean] Whether it outputs logs or not
    # @return [Integer] An ID of a saved Image record. nil will be returned if failed
    def self.save_image(attributes, logger, target_word=nil, tags=[], options={})
      # Skip the image if src_url is duplicate
      if options[:validation] and Scrape.is_duplicate(attributes[:src_url])
        logger.info 'Skipping a duplicate image...' if options[:verbose]
        return
      end

      # Remove all 4 bytes characters
      # Because with the old version of the MySQL we cannot save them to any columns.
      attributes[:caption] = Scrape.remove_4bytes(attributes[:caption])
      attributes[:title] = Scrape.remove_4bytes(attributes[:title])
      attributes[:artist] = Scrape.remove_4bytes(attributes[:artist])

      # Create a new instance and associate tags with it
      image = Image.new attributes
      tags.each { |tag| image.tags << tag }

      # Skip the image if it's irrelevant, like porns and cosplay images
      if self.check_banned(image)
        logger.info 'Skipping an irrelevant image...' if options[:verbose]
        return
      end


=begin
      # If the image is a photo, save it to another table for machine learning
      # Return nil in either case
      if self.check_photo(image)
        Scrape::Client.save_photo(attributes, tags, options)
        logger.info 'Saving a photo image as a Photo record...'
        return
      end
      # Return if site's name is Tumblr anyway.
      return if image.site_name = 'tumblr'
=end


      # Use src_url as original_url if the latter one is nil
      image.original_url = image.src_url if image.original_url.nil?

      # Use 'save' method as it could fail frequently
      if image.save(validate: options[:validation])

        # Associate the image to the TargetWord object
        # If nil(such as in case of scraping RSS, etc), we run the script later and associate it separately
        target_word.images << image unless target_word.nil?
        Scrape::Client.generate_jobs(image.id, 'Image', attributes[:src_url], options[:large]) unless options[:resque]
      else
        logger.info 'Image model saving failed. (maybe due to duplication)'
        return
      end

      image.id
    end

    # Create a new Photo record
    def self.save_photo(attributes, tags=[], options={})
      puts attributes.inspect
      photo = Photo.new attributes
      tags.each { |tag| photo.tags << tag }
      photo.original_url = photo.src_url if photo.original_url.nil?

      # Use 'save' method as it could fail frequently
      if photo.save(validate: options[:validation])
        Scrape::Client.generate_jobs(photo.id, 'Photo', attributes[:src_url], options[:large]) unless options[:resque]
      end
    end


    # Enqueues a resque job that downloads an image.
    # @params image_id [Integer] An ID of an image that you wanna it download.
    # @params src_url [String] A source url string.
    # @params large [Boolean] Whether its file size is beyond 2 MB.
    # @params user_id [Integer]
    # @params target_type [String] A string that represents a class name.
    # @params target_id [Integer]
    # @params logger [Logger] An instance of a logger class that is derived from Rails Logger class.
    def self.generate_jobs(image_id, image_type, src_url, large=false, user_id=nil, target_type=nil, target_id=nil, logger=nil)
      if user_id and target_type and target_id
        if large
          Resque.enqueue(DownloadImageLarge, image_id, image_type, src_url,
            user_id, target_type, target_id)
        else
          Resque.enqueue(DownloadImage, image_id, image_type, src_url,
            user_id, target_type, target_id)
        end
      else
        if large
          Resque.enqueue(DownloadImageLarge, image_id, image_type, src_url)
        else
          Resque.enqueue(DownloadImage, image_id, image_type, src_url)
        end
      end
    end

    # Send an email that indicates there was an error.
    # @param e [Exception]
    # @param module_type [String]
    # @param target_word [TargetWord]
    def send_error_mail(e, module_type, target_word, info=nil)
      begin
        ActionMailer::Base.mail(
          :from => "noreply@ispicks.com",
          :to => CONFIG['gmail_username'], :subject => "crawl_error #{module_type}",
          :body => "#{e.inspect}\n\ntarget_word:#{target_word.inspect}\n\nperson:#{target_word.person.inspect}\n\n#{e.backtrace.join("\n")}\n\ninfo:#{info}"
        ).deliver
      rescue => e
        @logger.error e.inspect
        @logger.error 'Sending an error email has failed!'
      end
    end

  end
end
