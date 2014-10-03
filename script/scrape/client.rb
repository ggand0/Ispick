#require 'scrape'

module Scrape

  # The base(parent) class of scraping classes.
  # スクレイピング処理を行うクラス群の親クラス
  class Client
    include Scrape
    attr_accessor :logger, :limit, :pid_debug, :sleep_debug
    ROOT_URL = ''

    # Initializes a new Client object
    #
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

    # Print debugging info
    def _print
      require 'objspace'
      @logger.debug "count_objects:#{ObjectSpace.count_objects}" #=> {:TOTAL=>55298, :FREE=>10289, :T_OBJECT=>3371, ...}
      @logger.debug "memsize_of_all:#{ObjectSpace.memsize_of_all}" # Display all memory usage in bytes
    end


    # 定時配信時、タグ検索APIを用いて抽出するサイト用の関数
    # Scrape images from websites which has api. The latter two params are used for testing.
    # @param module_type [String]
    # @param [Integer] min
    # @param logger [Logger] logger instance to output logs.
    # @param [Boolean] whether it's called for debug or not
    # @param [Boolean] whether it's called for debug or not
    def scrape_target_words(module_type, interval=60)
      # 予備時間が十分に取れない程短時間の場合は例外を発生させる
      if interval < 15
        raise Exception.new('the interval argument must be more than 10!')
        return
      end
      reserved_time = 10
      local_interval = (interval-reserved_time) / (TargetWord.count*1.0)
      @logger.info '--------------------------------------------------'
      @logger.info "Start extracting from #{self.class::ROOT_URL}"
      @logger.info "interval=#{interval} local_interval=#{local_interval}"

      # PIDファイルを用いて多重起動を防ぐ
      detect_multiple_running(false)


      # １タグごとにタグ検索APIを用いて画像取得
      count = 0
      target_word = TargetWord.first
      while (count < TargetWord.count) do
        begin
          crawl_target_word(module_type, target_word)
        rescue => e
          @logger.info e
          logger.error "Scraping from #{self.class::ROOT_URL} has failed!"

          # Send an email manually
          if Rails.env.production?
            send_error_mail(e, module_type, target_word)
          end
        end

        begin
          # nextメソッドを使用してtarget_wordの次にidの若いレコードを取得
          target_word = target_word.next
          count+=1

          # 計算した時間分sleep
          sleep_time = local_interval*60
          logger.info "Sleeping #{local_interval} minutes."
          sleep(sleep_time) unless @sleep_debug
        rescue Exception => e
          # Standard errorのみcatchするので、メモリーリークした場合はここでkernelにkillされる
          puts e.inspect
        end

      end
      @logger.info '--------------------------------------------------'
    end

    def crawl_target_word(module_type, target_word)
      # パラメータに基づいてAPIリクエストを行い結果を得る
      if (not target_word.name.nil?) and (not target_word.name.empty?)
        @logger.debug "target_word_id: #{target_word.id}"

        # デフォルトのパラメータで実行
        result = scrape_using_api(target_word)
        puts result.inspect
        @logger.info "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, skipped: #{result[:skipped]}, avg_time: #{result[:avg_time]}"

        # 英語メインのサイトの場合は英名でも検索する
        if module_type == 'Scrape::Tumblr' or module_type == 'Scrape::Anipic'
          # english=trueで呼ぶ
          result = scrape_using_api(target_word, nil, true, false, true)
          @logger.info "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, skipped: #{result[:skipped]}, avg_time: #{result[:avg_time]}"
        end

        target_word.crawl_count += 1
        target_word.save!
      end
    end


    # 派生クラスでoverrideして使う。
    def scrape_using_api(target_word)
      { scraped: 0, duplicates: 0, skipped: 0, avg_time: 0 }
    end


    # PIDファイルを用いて多重起動を防ぐ。pidfile gem使用。
    # @param [Boolean] PidFileを使用するかどうか
    # @param [Boolean] デバッグ出力を行うかどうか
    def detect_multiple_running(debug=false)
      unless @pid_debug
        if PidFile.running? # PidFileが存在する場合はプロセスを終了する
          @logger.info 'Another process is already runnnig. Exit.'
          exit
        end

        # PidFileが存在しない場合、新たにPidFileを作成し、
        # 新たにプロセスが生成されるのを防ぐ
        pid_hash = {
          #pidfile: "#{module_type}.pid",
          pidfile: "#{self.class.name}.pid",
          piddir: "#{Rails.root}/tmp/pids"
        }
        p = PidFile.new(pid_hash)

        # デフォルトでは/tmp以下にPidFileが作成される
        @logger.debug 'PidFile DEBUG:'
        @logger.debug p.pidfile
        @logger.debug p.piddir
        @logger.debug p.pid
        @logger.debug p.pidpath
      end
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

    def self.check_banned(image)
      return true if Obscenity.profane?(image.title)
      return true if Obscenity.profane?(image.caption)

      if (not image.tags.nil?) and (not image.tags.empty?)
        return true if self.is_banned(image.tags)
      end
      false
    end


    # Create new image instanace and save it to the database.
    # Imageレコードを新たに生成してDBに保存する
    # @param [Hash] Imageレコードに与える属性のHash
    # @param [Array] 関連するタグ(String)の配列
    # @param [Boolean] validationを行うかどうか
    # @param [Boolean] 大きいサイズの画像かどうか
    # @param [Boolean] ログ出力を行うかどうか
    # @return [Integer] 保存されたImageレコードのID。失敗した場合はnil
    def self.save_image(attributes, logger, target_word=nil, tags=[], options={})
      # Skip the image if src_url is duplicate
      # src_urlが重複していればskip
      if options[:validation] and Scrape.is_duplicate(attributes[:src_url])
        logger.info 'Skipping a duplicate image...' if options[:verbose]
        return
      end

      # Remove 4 bytes chars
      # Because with the old version of the MySQL we cannot save them to any columns.
      attributes[:caption] = Scrape.remove_4bytes(attributes[:caption])

      # Create a new instance and associate tags
      image = Image.new attributes
      tags.each { |tag| image.tags << tag }

      # Skip the image if it's irrelevant, like porns and cosplay images
      return if self.check_banned(image)

      # Use src_url as original_url if the latter one is nil
      image.original_url = image.src_url if image.original_url.nil?

      # 高頻度で失敗し得るのでsave!ではなくsaveを使用する
      # ダウンロード・特徴抽出処理をgenerate_jobs内で非同期的に行う
      if image.save(validate: options[:validation])

        # target_wordオブジェクトに関連づける
        # nilの場合(RSSのスクレイピング時等)は、後でスクリプトを走らせて別途関連づける
        target_word.images << image unless target_word.nil?

        Scrape::Client.generate_jobs(image.id, attributes[:src_url], options[:large]) unless options[:resque]
      else
        logger.info 'Image model saving failed. (maybe due to duplication)'
        return
      end
      image.id
    end


    # Enqueues a resque job that downloads an image.
    # 既にsaveしたImageレコードに対してダウンロード・画像解析処理を
    # Resqueのjobとして行う（非同期的に）
    # @params image_id [Integer] An ID of an image that you wanna it download.
    # @params src_url [String] A source url string.
    # @params large [Boolean] Whether its file size is beyond 2 MB.
    # @params user_id [Integer]
    # @params target_type [String] A string that represents a class name.
    # @params target_id [Integer]
    # @params logger [Logger] An instance of a logger class that is derived from Rails Logger class.
    def self.generate_jobs(image_id, src_url, large=false, user_id=nil, target_type=nil, target_id=nil, logger=nil)
      if user_id and target_type and target_id
        if large
          Resque.enqueue(DownloadImageLarge, image_id, src_url,
            user_id, target_type, target_id)
        else
          #logger.info "with #{user_id}: #{image_id}" if logger
          Resque.enqueue(DownloadImage, image_id, src_url,
            user_id, target_type, target_id)
        end
      else
        if large
          Resque.enqueue(DownloadImageLarge, image_id, src_url)
        else
          #logger.info "without #{user_id}: #{image_id}" if logger
          Resque.enqueue(DownloadImage, image_id, src_url)
        end
      end
    end

    def send_error_mail(e, module_type, target_word)
      begin
        ActionMailer::Base.mail(
          :from => "noreply@ispicks.com",
          :to => CONFIG['gmail_username'], :subject => "crawl_error #{module_type}",
          :body => "#{e.inspect}\n\ntarget_word:#{target_word.inspect}"
        ).deliver
      rescue => e
        #puts e.inspect
        @logger.error e.inspect
        @logger.error 'Sending an error email has failed!'
      end
    end

  end
end
