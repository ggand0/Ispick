# coding: utf-8
require "#{Rails.root}/script/scrape/client"
require 'open-uri'


module Scrape
  class Nico < Client
    RSS_URL = 'http://seiga.nicovideo.jp/rss/illust/new'
    NEW_IMAGES_URL = 'http://seiga.nicovideo.jp/illust/list'
    TAG_SEARCH_URL = 'http://seiga.nicovideo.jp/api/tagslide/data'
    ROOT_URL = 'http://seiga.nicovideo.jp'
    USER_SEARCH_URL= 'http://seiga.nicovideo.jp/api/user/info'
    USER_IMAGE_URL = 'http://seiga.nicovideo.jp/api/user/data'


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
      scrape_popular_images()
      scrape_ranking_images()
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
    
    # scrape images over 'threshold', from 'from_day' to 'to_day'.
    def scrape_popular_images(target_word=nil,from_day=DateTime.now-1,to_day=DateTime.now, threshold=200,user_id=nil, validation=true, verbose=false)
      result_hash = Scrape.get_result_hash
      
      # Get the xml file with api response
      agent = self.class.get_client
      flg = 0
      page_num=0
      while(flg==0)
        page_num = page_num+1
        url = NEW_IMAGES_URL + "?page=#{page_num}"
        xml = agent.get(url)
        puts(page_num)
        xml.search("div[class='illust_list']").search("a").each do |item|
          #compare popularity to threshold (popularity = 'view' or 'comment' or 'clip')
          if item.search("li[class='clip']").text.to_i >= threshold then
              page_url = ROOT_URL + item.attr("href")
              page = agent.get(page_url)
              start = Time.now
              
              # skip adult illust
              begin
                image_data = self.class.get_data2(page)
                @logger.debug "src_url: #{image_data[:src_url]}"
              rescue => e
                @logger.error "An error has occurred inside get_data method."
                next
              end
              
              #compare posted_at to from_day and to_day
              if image_data[:posted_at] >= from_day && image_data[:posted_at] <= to_day then

                #save image_data
                options = Scrape.get_option_hash(validation, false, false, (not user_id.nil?))
                # get tags information
                tags = page.search("meta[name='keywords']").attr("content").value.split(",")
                image_id = self.class.save_image(image_data, @logger, target_word, Scrape.get_tags(tags), options)

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
                  
              # past than from_day
              elsif image_data[:posted_at] < from_day then
                flg = 1
                break                
              end              
=begin
              # There is no api(using img_num) for extracting illust information???
              # by way of user information
              page = agent.get(page_url)
              user_id = page.search("div[class='user']").attr("data-id").value
              image_id = item.attr("href").split("/")[2]
              url = USER_IMAGE_URL + "?id=#{user_id}"
              user_info = agent.get(url)
              user_info.search("image").each do |image|
                if image.search("id").text == image_id then
                  image_data = self.class.get_data(image)
                  break
                end
              end
=end
          end          
        
        end
      
      end
      
      result_hash[:avg_time] = result_hash[:avg_time] / ((result_hash[:scraped]+result_hash[:duplicates])*1.0)
      result_hash

    end
    
    # scrape images from yesterday ranking
    def scrape_ranking_images(target_word=nil, user_id=nil, validation=true, verbose=false)
      result_hash = Scrape.get_result_hash
      
      # Get the xml file with api response
      agent = self.class.get_client
      ranking_url = "http://ext.seiga.nicovideo.jp/api/illust/blogparts?mode=ranking&key=daily%2call"
      ranking = agent.get(ranking_url)
      
      ranking.search("image").each do |image|
        page_url = ROOT_URL+"/seiga/im#{image.search("id").text}"
        start = Time.now
        page = agent.get(page_url)
 
        # skip adult illust
        begin
          image_data = self.class.get_data2(page)
          @logger.debug "src_url: #{image_data[:src_url]}"
        rescue => e
          @logger.error "An error has occurred inside get_data method."
          next
        end

         #save image_data
        options = Scrape.get_option_hash(validation, false, false, (not user_id.nil?))
        # get tags information
        tags = page.search("meta[name='keywords']").attr("content").value.split(",")
        image_id = self.class.save_image(image_data, @logger, target_word, Scrape.get_tags(tags), options)

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
      end
      
      result_hash[:avg_time] = result_hash[:avg_time] / ((result_hash[:scraped]+result_hash[:duplicates])*1.0)
      result_hash

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
            self.class.generate_jobs(image_id, 'Image', image_data[:src_url], false, user_id,
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

    # For extracting popular images
    # @param [String] image page url
    # @return [Hash] Attributes of Image model
    def self.get_data2(page)
      src_url = page.search("meta[property='og:image']").attr("content").value
      size = FastImage.size(src_url)

      {
        artist: page.search("meta[property='og:title']").attr("content").value.split("\/")[1].split("さん")[0].gsub(" ",""),
        poster: nil,
        title: page.search("meta[property='og:title']").attr("content").value,
        caption: page.search("meta[name='description']").attr("content").value,
        src_url: src_url,
        page_url: page.search("link[rel='canonical']").first.attr("href"),
        #original_url: "http://seiga.nicovideo.jp/image/source/#{nico_image_id}",
        original_url: src_url,
        original_width: size[0],
        original_height: size[1],
        original_view_count: page.search("li[class='view']").first.content.gsub("閲覧","").to_i,
        original_favorite_count: page.search("li[class='clip']").first.content.gsub("クリップ","").to_i,
        # Parse JST posted_at datetime to utc
        # JSTの投稿日時が返却されるのでUTCに変換する
        posted_at: DateTime.strptime(page.search("li[class='date']").first.content, "%Y年%m月%d日 %H:%M").in_time_zone('Asia/Tokyo').utc,
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
      
      #agent.ssl_version = 'SSLv3'
      agent.ssl_version = :TLSv1

      agent.keep_alive = false
      #agent.read_timeout = 180 # [sec]
      agent.post('https://secure.nicovideo.jp/secure/login?site=seiga',
        'mail' => CONFIG['nico_email'], 'password' => CONFIG['nico_password'])
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
