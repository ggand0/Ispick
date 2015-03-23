# coding: utf-8
require 'open-uri'

# Scrape images from DeviantART
module Scrape
  class Deviant < Client
    # -------------------------------------------------------------
    # Use official api
    # boost%3Apopular : 人気順
    # max_age%3A24h   : 24時間以内のimage
    # in%3A{~~~}      : {~~~}カテゴリ内のimage
    # documents       : http://b.hatena.ne.jp/pentiumx/deviantart/
    # -------------------------------------------------------------

    ROOT_URL = "http://backend.deviantart.com/rss.xml?type=deviation&q=boost%3Apopular+max_age%3A24h"

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
      # manga, fanart, digitalart, traditional, (+anthro, cartoon), or all
      get_rss("manga", 300)
      get_rss("fanart", 300)
      get_rss("digitalart", 300)
      get_rss("traditional", 300)
      get_rss("anthro", 300)
      get_rss("cartoon", 300)

    end
    
    # Get images greater than "score" in "category".
    def get_rss(category="all", score=300)

      result_hash = Scrape.get_result_hash
      
      rss_url = ROOT_URL + "+in%3A#{category}"
      @logger.info "Starting scraping from #{rss_url}..."

      xml = Nokogiri::XML(open(rss_url))
      puts 'Extracting : ' + rss_url

      count = 0
      #xml.css('item').map do |item|
      xml.css('item').each do |item|
        puts item.css("link").text
        break if count >= @limit
        # Skip adult image or it's not image
        next if item.css("media|rating").text == "adult"
        next if item.css("media|content").attr("medium").nil?
        next if item.css("media|content").attr("medium").value != "image"

        # Get page url
        page_url = item.css("link").text

        # Open the page with Nokogiri
        begin
          page = Nokogiri::HTML(open(page_url))
        rescue Exception => e
          @logger.error e.inspect
          @logger.error ('Could not open the page:')
          @logger.error page_url
          return
        end

        # Get image's data and save
        begin
          image_data = get_data(page, item)
          tags = get_tags_original(page)
          # Save if it's high quality
          if image_data[:original_favorite_count] >= score && self.is_illust(page) then      
            # Save image_data
            options = Scrape.get_option_hash(true, false, true, false)
            self.class.save_image(image_data, @logger, nil, Scrape.get_tags(tags), options)
            count=count+1
          end
        rescue Exception => e
          @logger.error e.inspect
          @logger.error ('Could not get image\'s features:')
          @logger.error page_url
          return
        end
        
      end
      
      @logger.info result_hash
      result_hash

    end

    # Get attributes of an image from an item of API response xml.
    # @param item [Nokogiri::XML::Element] An 'item' element from xml file
    # @return [Hash] A hash of image's attributes
    def get_data(page, item)
      # Get page_url
      page_url = item.css('link').first.content

      # Get stats
      stats = self.get_stats(page)
      
      # Get posted_at
      posted_at = item.css('pubDate').first.content
      posted_at = DateTime.parse(posted_at).utc

      # Get source url
      # There are "dev-content-full" and "dev-content-normal" links for full images and thumbnails
      main = page.css("img[class='dev-content-normal']").first
      puts main.inspect
      return if main.nil?

      image_data = {
        artist: item.css("media|credit[role='author']").first.content,
        title: item.css('title').first.content,
        caption: item.css('description').first.content,
        src_url: main['src'],
        page_url: page_url,
        posted_at: posted_at,
        original_url: item.css('media|content').attr('url').value,
        original_width: item.css('media|content').attr('width').value,
        original_height: item.css('media|content').attr('height').value,
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
    
    def get_tags_original(page)
      tags = []
      page.search("a[class='discoverytag']").each do |tag|
        tags.push(tag.attr("data-canonical-tag"))
      end
    
      return tags    
    end

    # Detect adult pages
    # @param html [Nokogiri::HTML] A HTML object to check
    # @return [Boolean] Whether the given page contains adult contents or not
    def self.is_adult(html)
      mature = html.css("div[class='dev-content-mature mzone-main']").first
      return true if not mature.nil?
      false
    end
    
    def is_illust(page)
      page.search("span[class='dev-about-breadcrumb']").search("a").each do |category|
        if category.text == "Photography"
          return false
        end
      end

      return true
    end

    # Get view count and favorites count on DeviantART from the source page of an image.
    # @params page [Nokogiri::HTML::Element] The source page of an image
    # @return [Hash] Data of statistics of an image
    def get_stats(page)
      # Extract the div and parse it to a hash that contains view count and favorite count
      stats = {}
      stats_elements =
        page.css("div[class='dev-right-bar-content dev-metainfo-content dev-metainfo-stats']").first

      stats_elements.css('dt').each do |node|
        # Parse strings to integers
        count = node.next_element.text      # Get the next page element, 'dd' tag
        count.gsub!(/(\n|,| |\(.*)/, '')    # Remove comma, whitespace, and the following strings from the parentheses
        stats[node.text] = count.to_i
      end

      stats
    end

  end
end
