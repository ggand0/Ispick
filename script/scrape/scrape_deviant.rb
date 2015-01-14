# coding: utf-8
require 'open-uri'


# Scrape images from DeviantART
module Scrape
  class Deviant < Client
    # -------------------------------------------------------------
    # Use official api
    # boost%3Apopular : 人気順
    # max_age%3A24h   : 24時間以内のimage
    # in%3Amanga      : mangaカテゴリ内のimage
    # documents       : http://b.hatena.ne.jp/pentiumx/deviantart/
    # -------------------------------------------------------------
    ROOT_URL = 'http://backend.deviantart.com/rss.xml?type=deviation&q=boost%3Apopular+max_age%3A24h+in%3Amanga%2Fdigital+anime'

    # Constructor.
    # @param logger [ActiveSupport::Logger]
    # @param limi [Integer] Maximum number of images to scrape
    def initialize(logger=nil, limit=200)
      self.limit = limit
      if logger.nil?
        self.logger = Logger.new('log/scrape_deviant_cron.log')
      else
        self.logger = logger
      end
      self.logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    end

    # The main method to scrape images
    def scrape
      result_hash = Scrape.get_result_hash
      @logger.info "Starting scraping from #{ROOT_URL}..."

      xml = Nokogiri::XML(open(ROOT_URL))
      puts 'Extracting : ' + ROOT_URL

      #xml.css('item').map do |item|
      xml.css('item').each_with_index do |item, count|
        break if count >= @limit
        image_data = get_data(item)
        next if image_data.nil?

        # Open page_url again to get Element object
        begin
          html = Nokogiri::HTML(open(image_data[:page_url]))
        rescue Exception => e
          @logger.info('Skipping an adult image...')
          return
        end

        if self.class.is_adult(html)
          # Skip adult images
          next
        else
          # Save it to DB otherwise
          self.get_contents(image_data, html)
        end
      end

      @logger.info result_hash
      result_hash
    end

    # Get attributes of an image from an item of API response xml.
    # @param item [Nokogiri::XML::Element] An 'item' element from xml file
    # @return [Hash] A hash of image's attributes
    def get_data(item)
      page_url = item.css('link').first.content

      # Open the page with Nokogiri
      begin
        html = Nokogiri::HTML(open(page_url))
      rescue Exception => e
        @logger.error e.inspect
        @logger.error ('Could not open the page:')
        @logger.error page_url
        return
      end

      # Get values
      stats = self.get_stats(html)
      posted_at = item.css('pubDate').first.content
      posted_at = DateTime.parse(posted_at).utc

      # Get source url
      # There are "dev-content-full" and "dev-content-normal" links for full images and thumbnails
      main = html.css("img[class='dev-content-normal']").first
      puts main.inspect
      return if main.nil?


      image_data = {
        title: item.css('title').first.content,
        caption: item.css('description').first.content,
        src_url: main['src'],
        page_url: page_url,
        posted_at: posted_at,
        site_name: 'deviantart',
        module_name: 'Scrape::Deviant',
        original_view_count: stats['Views'],
        original_favorite_count: stats['Favourites']
      }
      puts image_data[:src_url].inspect

      image_data
    end


    # Get extra attributes of an image baesd on image_data,
    # and also save it to the database.
    # @param image_data [Hash] Basic attributes of an image
    def get_contents(image_data, html)
      # Writes to log
      @logger.info image_data[:src_url]

      tag_string = html.css("meta[name='keywords']").attr('content').content
      tags = tag_string.split(', ')

      # Save it to the DB
      options = Scrape.get_option_hash(true, false, true, false)
      puts image_data[:src_url]
      self.class.save_image(image_data, @logger, nil, Scrape.get_tags(tags), options)
    end


    # Detect adult pages
    # @param html [Nokogiri::HTML] A HTML object to check
    # @return [Boolean] Whether the given page contains adult contents or not
    def self.is_adult(html)
      mature = html.css("div[class='dev-content-mature mzone-main']").first
      return true if not mature.nil?
      false
    end

    # Get view count and favorites count on DeviantART from the source page of an image.
    # @params html [Nokogiri::HTML::Element] The source page of an image
    # @return [Hash] Data of statistics of an image
    def get_stats(html)
      # Extract the div and parse it to a hash that contains view count and favorite count
      stats = {}
      stats_elements =
        html.css("div[class='dev-right-bar-content dev-metainfo-content dev-metainfo-stats'] dl").first

      stats_elements.css('dt').each do |node|
        # Parse strings to integers
        count = node.next_element.text      # Get the next html element, 'dd' tag
        count.gsub!(/(\n|,| |\(.*)/, '')    # Remove comma, whitespace, and the following strings from the parentheses
        stats[node.text] = count.to_i
      end

      stats
    end

  end
end