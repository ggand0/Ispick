# -*- coding: utf-8 -*-
# coding: utf-8
require 'securerandom'
require "#{Rails.root}/script/scrape/client"


module Scrape
  class Zerochan < Client
    ROOT_URL = 'http://www.zerochan.net/'

    def initialize(logger=nil, limit=100)
      self.limit = limit
      if logger.nil?
        self.logger = Logger.new('log/scrape_zerochan_cron.log')
      else
        self.logger = logger
      end
      self.logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    end


    # Scrape images from zerochan by using RSS.
    # @param [Integer] min
    def scrape(interval=60)
      #@limit = 100
      @logger = Logger.new('log/scrape_zerochan_cron.log')
      @logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
      scrape_RSS()
    end

    # Scrape images from zerochan by using the search form with TargetWord records.
    # @param [Integer] min
    def scrape_tag(interval=60)
      #@limit = 2000
      @logger = Logger.new('log/scrape_zerochan_cron.log')
      @logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
      scrape_target_words('Scrape::Zerochan', interval)
    end

    # Scrape images using TargetWord records.
    # @param target_word [TargetWord]
    def scrape_target_word(user_id, target_word, english=false)
      @logger.info "Extracting #{@limit} images from: #{ROOT_URL}"

      result = scrape_using_api(target_word, user_id, true, true, english)
      @logger.info "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, skipped: #{result[:skipped]}, avg_time: #{result[:avg_time]}"
    end




    def self.get_agent
      agent = Mechanize.new
      agent.ssl_version = 'SSLv3'
      agent.keep_alive = false
      agent
    end

    # Get the result of search, using Mechanize.
    # @param query [String] Query string
    # @return [Mechanize::Page] A Mechanize::Page instance, initialized with a search result page
    def get_search_result(query)
      agent = Mechanize.new
      agent.ssl_version = 'SSLv3'
      agent.keep_alive = false
      page = agent.get(ROOT_URL)

      page.forms[0]['q'] = query
      result = page.forms[0].submit

      result
    end


    # Scrape images that have target tags.
    # @param target_word [TargetWord] A TargetWord record.
    # @param user_id [Integer] Not in use currently.
    # @param validation [Boolean] Whether it validates values during saving
    # @param logging [Boolean] Whether it outputs logs or not
    # @param english [Boolean] Whether it's an English target_word or not
    # @return [Hash] Summary of scraping
    def scrape_using_api(target_word=nil, user_id=nil, validation=true, logging=true, english=false)
      result_hash = Scrape.get_result_hash

      # Get query string
      if english
        query = Scrape.get_query_en(target_word, 'english')
      else
        query = Scrape.get_query_en(target_word, '')
      end
      if query.nil? or query.empty?
        result_hash[:info] = 'query was nil or empty'
        return result_hash
      end
      # =====================================================
      #   Append 'solo' keyword for creating better dataset
      # =====================================================
      query << ',solo'


      # On zerochan 0th page and 1st page are the same.
      page_num = 0
      @count = 0
      page = self.get_search_result(query)
      url_base = page.uri.to_s


      # Scrape images page by page
      while page.search("div[id='content']").count != 0 and @count < @limit
        page_num += 1
        url = url_base + "?p=#{page_num}"  # Append a page num parameter to the base url
        @logger.debug url
        page = Nokogiri::HTML(open(url))    # Use Nokogiri from the second time

        # Scrape images in a page and save them to the DB
        result_hash = self.scrape_page(page, result_hash, target_word, user_id, validation, logging)
      end
      result_hash
    end


    # Scrape images in a list page. Calls get_data method directly inside the method.
    # @param page [Mechanize::Page]
    # @param result_hash [Hash]
    # @param user_id [Integer] Not in use currently.
    # @param validation [Boolean] Whether it validates values during saving
    # @param logging [Boolean] Whether it outputs logs or not
    def scrape_page(page, result_hash, target_word, user_id, validation, logging)
      page.search("div[id='content']").first.search("ul[id='thumbs2']").first.search("li").each do |item|
        @count += 1
        start = DateTime.now

        id = item.search("a").first.attributes["href"].value.gsub("\/","")    # Get id of image
        image_url = item.search("img").first.attribute("src").value         # Get URL of image
        page_url = ROOT_URL + id.to_s                                       # Get URL of detail page
        html = Nokogiri::HTML(open(page_url))#agent.get(page_url)                                          # Parse the detail page

        # Get attributes of an image. If failed, move on to the next element.
        tags = self.get_tags_original(html)
        begin
          image_data = self.get_data(html, id)
        rescue => e
          puts e.inspect
          puts e.backtrace
          @logger.error e.inspect
          @logger.error e.backtrace
          @logger.error "get_data method failed:"
          @logger.error page_url
          next
        end
        options = Scrape.get_option_hash(validation, false, true, (not user_id.nil?))
        image_id = self.class.save_image(image_data, @logger, target_word, Scrape.get_tags(tags), options)

        result_hash[:duplicates] += image_id ? 0 : 1
        result_hash[:scraped] += 1 if image_id
        elapsed_time = Time.now - start
        result_hash[:avg_time] += elapsed_time
        @logger.info "Scraped from #{image_data[:src_url]} in #{elapsed_time} sec" if logging

        # Scrape images until it reaches @limit num
        break if @count >= @limit

        # ===================================================
        #   Sleep 1 sec since we scrape a lot of images
        # ===================================================
        sleep(1)
      end

      result_hash
    end




    def scrape_RSS(target_word=nil, user_id=nil, validation=true, logging=true, english=false)
      result_hash = Scrape.get_result_hash
      agent = self.class.get_agent
      start = Time.now

      # ページ数
      page_count = 0
      count = 0
      # 抽出したイラスト数
      image_data = {}
      image_data[:posted_at] = DateTime.now.to_date
      yesterday = Date.today - 1.day

      # 当日中のイラスト
      #while(image_data[:posted_at].to_date == DateTime.now.to_date and count<limit)
      while(image_data[:posted_at].to_date - yesterday) <= 1 and count < @limit
        page_count = page_count+1
        rss_url = ROOT_URL + "?p=" + page_count.to_s

        begin
          page = agent.get(rss_url)#SocketError: getaddrinfo: nodename nor servname provided, or not known
        rescue => e
          @logger.error e.inspect
          @logger.error "zerochan server is down. Aborting..."
          break
        end

        page.search("div[id='content']").first.search("ul[id='thumbs2']").first.search("li").each do |item|
          count = count + 1

          id = item.search("a").first.attributes["href"].value.gsub("\/","")  # 画像のidを取得
          image_url = item.search("img").first.attribute("src").value         # 画像のURLを取得
          page_url = ROOT_URL + id.to_s                                       # 詳細ページのURLを取得
          html = agent.get(page_url)                                          # 詳細ページをパース
          tags = self.get_tags_original(html)
          image_data = self.get_data(html, id)

          options = Scrape.get_option_hash(validation, false, true, (not user_id.nil?))
          # 保存に必要なものはimage_data, tags, validetion
          image_id = self.class.save_image(image_data, @logger, target_word, Scrape.get_tags(tags), options)

          result_hash[:duplicates] += image_id ? 0 : 1
          result_hash[:scraped] += 1 if image_id
          elapsed_time = Time.now - start
          result_hash[:avg_time] += elapsed_time
          @logger.info "Scraped from #{image_data[:src_url]} in #{elapsed_time} sec" if logging

          # Resqueで非同期的に画像解析を行う
          # 始めに画像をダウンロードし、終わり次第ユーザに配信
          if image_id and (not user_id.nil?)
            self.class.generate_jobs(image_id, 'Image', image_data[:src_url], false, target_word.class.name, target_word.id)
          end

          # limitを越えるか、その日に投稿された画像でなくなるまで
          #break if count >= limit || image_data[:posted_at].to_date != DateTime.now.to_date
          @logger.debug image_data[:posted_at].to_date
          @logger.debug count >= @limit or (image_data[:posted_at].to_date - yesterday) <= 0
          break if count >= @limit or (image_data[:posted_at].to_date - yesterday) <= 0
        end

      end

      result_hash[:avg_time] = result_hash[:avg_time] / ((result_hash[:scraped]+result_hash[:duplicates])*1.0)
      result_hash
    end


    # htmlからタグを取得
    # @param [Nokogiri::HTML]
    # @return [Array::String]
    def get_tags_original(html)
      result = []

      html.search("ul[id='tags']").first.search("a").each do |a|
        result << a.content
      end

      return result
    end

    # Extract posted_at time string from a given html and convert it to a Time object.
    # @param page [Nokogiri::HTML] The source page of an image
    # @return [Time] The time when the image was posted at
    def self.get_time(page)

      begin
        if page.search("div[id='content']").children[5].search('span').count == 1
          # '1 week ago' or '5 days ago' style
          # =========================================================
          #<p>
          #  Entry by <a href="/user/Sakuta+Baby">Sakuta Baby</a>
          #  <span title="Mon Jan  5 08:36:12 2015">5 days ago</span>
          #</p>
          # =========================================================
          time = Time.parse( page.search("div[id='content']").first.search("span")[0].attr('title') )
        else
          # Normal datetime style
          # =========================================================
          #<p>
          #  Entry by <a href="/user/Artificial+Enemy">Artificial Enemy</a>
          #    on Tue Aug 14 19:52:31 2012
          #</p>
          # =========================================================
          tmp = page.search("div[id='content']").first.search('p')[0].content
          time_string = tmp.match(/\son\s.*\d\d:\d\d:\d\d\s\d\d\d\d/).to_s.gsub(/\son\s/, '')
          time = Time.parse(time_string)
        end
      rescue ArgumentError => e
        # Rescue the case which the page doesn't have any time strings
        # =========================================================
        #<p>
        #  Entry by <a href="/user/Hatsune_Miku_Lover">Hatsune_Miku_Lover</a>
        #</p>
        # =========================================================
        time = nil
      end

      time
    end

    # 画像１枚に関する情報をHashにして返す。
    # original_favorite_countの抽出にはVotesを利用
    # @param [Nokogiri::HTML]
    # @param [String]
    # @return [Hash]
    def get_data(page, id)
      title = page.search("title").first.content
      caption = page.search("div[id='content']").first.search("h1").first.content
      #
      time = self.class.get_time(page)
      src_url = page.search("div[id='large']").first.search("img").first.attr('src')
      original_url = page.search("div[id='large']").first.css("img").first.attr('src')

      favorite_count = nil
      resolution =  page.search("div[id='large']").first.css('p')[1].children[0].content
      size = resolution.split('x')

      hash = {
        title: title,
        caption: caption,
        page_url: ROOT_URL + "#{id}",
        posted_at: time,
        original_view_count: nil,
        src_url: src_url,
        original_url: original_url,
        original_favorite_count: favorite_count,             # Image Rating
        site_name: 'zerochan',
        module_name: 'Scrape::Zerochan',
        artist: nil,
        original_height: size[1],
        original_width: size[0],
      }

      return hash
    end



=begin
    # Mechanizeにより検索結果を取得
    # @param [String]
    # @return [Mechanize] Mechanizeのインスタンスを初期化して返す
    def get_search_result(query)
      agent = Mechanize.new
      agent.ssl_version = 'SSLv3'
      page = agent.get(ROOT_URL+'login')

      # login作業
      page.forms[1]['name'] = CONFIG['zerochan_username']
      page.forms[1]['password'] = CONFIG['zerochan_password']
      result = page.forms[1].click_button()

      return result
    end
=end
  end
end
