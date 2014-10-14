# coding: utf-8
require "#{Rails.root}/script/scrape/client"
require 'open-uri'


module Scrape
  class Nico < Client
    RSS_URL = 'http://seiga.nicovideo.jp/rss/illust/new'
    TAG_SEARCH_URL = 'http://seiga.nicovideo.jp/api/tagslide/data'
    ROOT_URL = 'http://seiga.nicovideo.jp'
    USER_SEARCH_URL= 'http://seiga.nicovideo.jp/api/user/info'


    def initialize(logger=nil, limit=50)
      self.limit = limit
      if logger.nil?
        self.logger = Logger.new('log/scrape_nico_cron.log')
      else
        self.logger = logger
      end
      self.logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    end

    # Scrape images from nicoseiga, using all TargetWord records.
    # @param interval [Integer] The frequency of scraping images from NicoSeiga[min].
    def scrape(interval=60)
      scrape_target_words('Scrape::Nico', interval)
    end


    # Scrape images from nicoseiga, using single TargetWord object.
     # キーワードによる検索・抽出を行う
    # @param user_id [Integer]
    # @param target_word [TargetWord]
    def scrape_target_word(user_id, target_word)
      @limit = 10
      @logger.info "Extracting #{@limit} images from: #{ROOT_URL}"

      result = scrape_using_api(target_word, user_id, true)

      @logger.info "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, avg_time: #{result[:avg_time]}"
    end

    # Scrape images from nicoseiga, using its (probablly unofficial) API.
    # キーワードからタグ検索してlimit分の画像を保存する
    # @param target_word [TargetWord] A TargetWord object to scrape.
    # @param user_id [Integer] An id value of certain user, if necessary.
    # @param validation [Boolean] Whether it needs to validate records or not.
    # @return verbose [Hash] Output verbose log when it's true.
    def scrape_using_api(target_word, user_id=nil, validation=true, verbose=false)
      result_hash = Scrape.get_result_hash
      query = Scrape.get_query target_word
      if query.nil? or query.empty?
        result_hash[:info] = 'query was nil or empty'
        return result_hash
      end

      # Get the xml file with api response
      @logger.info "query=#{query}"
      agent = self.class.get_client
      url = "#{TAG_SEARCH_URL}?page=1&query=#{query}"
      escaped = URI.escape(url)
      xml = agent.get(escaped)

      # 画像情報を取得してlimit枚DBヘ保存する
      xml.search('image').take(@limit).each_with_index do |item, count|
        begin
          # Skip adult images and ones that have 0 clip count
          if item.css('adult_level').first.content.to_i > 1 || item.css('clip_count').first.content.to_i == 0
            result_hash[:skipped] += 1
            next
          end

          start = Time.now
          image_data = self.class.get_data(item)             # APIの結果から画像情報取得
          options = Scrape.get_option_hash(validation, false, false, (not user_id.nil?))
          image_id = self.class.save_image(image_data, @logger, target_word, [ Scrape.get_tag(query) ], options)

          result_hash[:duplicates] += image_id ? 0 : 1
          result_hash[:scraped] += 1 if image_id
          elapsed_time = Time.now - start
          result_hash[:avg_time] += elapsed_time

          # Resqueで非同期的に画像解析を行う
          # 始めに画像をダウンロードし、終わり次第ユーザに配信
          if image_id and (not user_id.nil?)
            #@logger.debug "scrape_nico: user=#{user_id}"
            @logger.info "Scraped from #{image_data[:src_url]} in #{elapsed_time} sec" if verbose and image_id
            self.class.generate_jobs(image_id, image_data[:src_url], false, user_id,
              target_word.class.name, target_word.id, @logger)
          end

          break if result_hash[:duplicates] >= 3
        rescue => e
          # 検索結果が0の場合など
          @logger.error e
          next
        end
        break if count+1 >= @limit
      end

      result_hash[:avg_time] = result_hash[:avg_time] / ((result_hash[:scraped]+result_hash[:duplicates])*1.0)
      result_hash
    end

    # Construct attributes of Image model basted on a HTML object
    # @param [Nokogiri::HTML] A html object which you wanna retrieve images
    # @return [Hash] Attributes of Image model
    def self.get_data(item)
      nico_image_id = item.css('id').first.content
      src_url = "http://lohas.nicoseiga.jp/thumb/#{nico_image_id}i"
      size = FastImage.size(src_url)

      {
        artist: item.css('nickname').first.content,
        poster: nil,
        title: item.css('title').first.content,
        caption: item.css('description').first.content,
        src_url: src_url,
        page_url: "http://seiga.nicovideo.jp/seiga/im#{nico_image_id}",
        #original_url: "http://seiga.nicovideo.jp/image/source/#{nico_image_id}",
        original_url: src_url,
        original_width: size[0],
        original_height: size[1],
        original_view_count: item.css('view_count').first.content,
        original_favorite_count: item.css('clip_count').first.content,
        # Parse JST posted_at datetime to utc
        # JSTの投稿日時が返却されるのでUTCに変換する
        posted_at: DateTime.parse(item.css('created').first.content).in_time_zone('Asia/Tokyo').utc,
        site_name: 'nicoseiga',
        module_name: 'Scrape::Nico',
      }
    end

    # [OLD]Scrape contents with actual HTML page based on page_url value.
    # @param page_url [String]
    # @param agent [Mechanize]
    # @param image_data [Hash]
    # @param validation [Boolean]
    def self.get_contents(page_url, agent, image_data, validation=true)
      start = Time.now
      begin
        page = agent.get(page_url)  # 元ページを開く
      rescue Exception => e         # ログイン求められて失敗した場合など
        puts "Failed to open page_url: #{page_url}"
        puts e
        Rails.logger.info('Could not open a page.')
        return
      end

      # タグ情報を取得
      tag_string = page.at("meta[@name='keywords']").attr('content')
      tags = Scrape.get_tags(tag_string.split(','))

      puts "Updated in #{(Time.now - start).to_s} sec"
    end

    # Login to the NicoSeiga with Mechanize.
    # @return [Mechanize] Mechanizeのインスタンスを初期化して返す
    def self.get_client
      agent = Mechanize.new
      agent.ssl_version = 'SSLv3'
      agent.post('https://secure.nicovideo.jp/secure/login?site=seiga',
        'mail' => CONFIG['nico_email'],'password' => CONFIG['nico_password'])
      agent
    end


    # delivered_images update用に、ログインしてstats情報だけ返す関数
    # @param [Mechanize]
    # @param [String]
    # @return [Hash]
    def self.get_stats(agent, page_url)
      begin
        page = agent.get(page_url)
        info_elements = page.at("ul[@class='illust_count']")
        original_view_count = info_elements.css("li[class='view']").css("span[class='count_value']").first.content
        comments = info_elements.css("li[class='comment']").css("span[class='count_value']").first.content
        clips = info_elements.css("li[class='clip']").css("span[class='count_value']").first.content
      rescue => e
        return false
      end

      { original_view_count: original_view_count, original_favorite_count: clips}
    end

  end
end
