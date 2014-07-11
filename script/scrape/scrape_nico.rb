# coding: utf-8
require "#{Rails.root}/script/scrape/client"
require 'open-uri'


module Scrape
  class Nico < Client
    RSS_URL = 'http://seiga.nicovideo.jp/rss/illust/new'
    TAG_SEARCH_URL = 'http://seiga.nicovideo.jp/api/tagslide/data'
    ROOT_URL = 'http://seiga.nicovideo.jp'


    def initialize(logger=nil, limit=50)
      self.limit = limit

      if logger.nil?
        self.logger = Logger.new('log/scrape_nico_cron.log')
      else
        self.logger = logger
      end
      self.logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    end

    # Scrape images from nicoseiga. The latter two params are used for testing.
    # @param [Integer] min
    def scrape(interval=60)
      scrape_target_words('Scrape::Nico', interval)
    end


    # キーワードによる検索・抽出を行う
    # @param target_word[TargetWord]
    def scrape_target_word(user_id, target_word)
      @limit = 10
      @logger.info "Extracting #{limit} images from: #{ROOT_URL}"

      result = scrape_using_api(target_word, user_id, true)
      @logger.info "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, avg_time: #{result[:avg_time]}"
    end

    # キーワードからタグ検索してlimit分の画像を保存する
    # @param [String]
    # @param [Integer]
    # @param [Boolean]
    # @return [Hash]
    def scrape_using_api(target_word, user_id=nil, validation=true, verbose=false)
      # nilのクエリは弾く
      query = Scrape.get_query target_word
      return if query.nil? or query.empty?

      @logger.info "query=#{query}"
      agent = self.class.get_client
      url = "#{TAG_SEARCH_URL}?page=1&query=#{query}"
      escaped = URI.escape(url)
      xml = agent.get(escaped)
      duplicates = 0
      scraped = 0
      avg_time = 0


      # 画像情報を取得してlimit枚DBヘ保存する
      xml.search('image').take(@limit).each_with_index do |item, count|
        begin
          next if item.css('adult_level').first.content.to_i > 0  # 春画画像をskip

          start = Time.now
          image_data = self.class.get_data(item)                        # APIの結果から画像情報取得
          options = {
            validation: validation,
            large: false,
            verbose: false,
            resque: false
          }
          image_id = self.class.save_image(image_data, @logger, [ Scrape.get_tag(query) ], options)

          duplicates += image_id ? 0 : 1
          scraped += 1 if image_id
          elapsed_time = Time.now - start
          avg_time += elapsed_time
          @logger.info "Scraped from #{image_data[:src_url]} in #{elapsed_time} sec" if verbose and image_id

          # Resqueで非同期的に画像解析を行う
          # 始めに画像をダウンロードし、終わり次第ユーザに配信
          if image_id
            Scrape.generate_jobs(image_id, image_data[:src_url], false, user_id, target_word.class.name, target_word.id)
          end

          break if duplicates >= 3
        rescue => e
          # 検索結果が0の場合など
          @logger.error e
          next
        end
        break if count+1 >= limit
      end

      { scraped: scraped, duplicates: duplicates, avg_time: avg_time / ((scraped+duplicates)*1.0) }
    end

    # Image modelのattributesを組み立てる
    # @param [Nokogiri::HTML]
    # @return [Hash]
    def self.get_data(item)
      {
        title: item.css('title').first.content,
        caption: item.css('description').first.content,
        src_url: "http://lohas.nicoseiga.jp/thumb/#{item.css('id').first.content}i",
        page_url: "http://seiga.nicovideo.jp/seiga/im#{item.css('id').first.content}",
        views: item.css('view_count').first.content,
        favorites: item.css('clip_count').first.content,
        # JSTの投稿日時が返却されるのでUTCに変換する
        posted_at: DateTime.parse(item.css('created').first.content).in_time_zone('Asia/Tokyo').utc,
        site_name: 'nicoseiga',
        module_name: 'Scrape::Nico',
      }
    end

    # [OLD]page_urlから情報・画像抽出する
    # @param [String]
    # @param [Mechanize]
    # @param [Hash]
    # @param [Boolean]
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

    # Mechanizeによるログインを行う
    # @return [Mechanize] Mechanizeのインスタンスを初期化して返す
    def self.get_client
      agent = Mechanize.new
      agent.ssl_version = 'SSLv3'
      agent.post('https://secure.nicovideo.jp/secure/login?site=seiga',
        'mail' => CONFIG['nico_email'],'password' => CONFIG['nico_password'])
      agent
    end


    # delivered_images update用に、
    # ログインしてstats情報だけ返す関数
    # @param [Mechanize]
    # @param [String]
    # @return [Hash]
    def self.get_stats(agent, page_url)
      begin
        page = agent.get(page_url)
        info_elements = page.at("ul[@class='illust_count']")
        views = info_elements.css("li[class='view']").css("span[class='count_value']").first.content
        comments = info_elements.css("li[class='comment']").css("span[class='count_value']").first.content
        clips = info_elements.css("li[class='clip']").css("span[class='count_value']").first.content
      rescue => e
        return false
      end

      { views: views, favorites: clips}
    end

  end
end