# -*- coding: utf-8 -*-
# coding: utf-8
require 'securerandom'
require "#{Rails.root}/script/scrape/client"


module Scrape
  class Shushu < Client
    ROOT_URL = 'http://e-shuushuu.net/'

    def initialize(logger=nil, limit=20)
      self.limit = limit
      if logger.nil?
        self.logger = Logger.new('log/scrape_shushu_cron.log')
      else
        self.logger = logger
      end
      self.logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    end

    # 取得するPostの上限数。APIの仕様で20postsが限度
    # Scrape images from shushu. The latter two params are used for testing.
    # @param [Integer] min
    # @param [Boolean] whether it's called for debug or not
    # @param [Boolean] whether it's called for debug or not
    def scrape(interval=60)
      @limit = 20
      @logger = Logger.new('log/scrape_shushu_cron.log')
      @logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
      #scrape_target_words('Scrape::Shushu', interval)
      scrape_RSS()
    end

    def scrape_RSS(target_word=nil, user_id=nil, validation=true, logging=false, english=false)
      duplicates = 0
      skipped = 0
      scraped = 0
      avg_time = 0
      start = Time.now
    
      rss_url = ROOT_URL + "index.rss"
      xml = Nokogiri::XML(open(rss_url))
      
      xml.search("item").each_with_index do |item,count|
          # 画像のidを取得        
        id = item.search("link").first.content.split("/")[4].split("-")[3].split(".")[0]
          # 画像のURLを取得
        image_url = item.search("link").first.content
          # 詳細ページのURLを取得
        page_url = ROOT_URL + "image/#{id}/"
        
        html = Nokogiri::HTML(open(page_url))

        tags = self.get_tags_original(html)
        image_data = self.get_data(html, id)
        #puts image_data
        
       options = {
          validation: validation,
          large: false,
          verbose: false,
          resque: true
        }
          # 保存に必要なものはimage_data, tags, validetion
        image_id = self.class.save_image(image_data, @logger, target_word, Scrape.get_tags(tags), options)

        duplicates += image_id ? 0 : 1
        scraped += 1 if image_id
        elapsed_time = Time.now - start
        avg_time += elapsed_time
        @logger.info "Scraped from #{image_data[:src_url]} in #{elapsed_time} sec" if logging

#=begin
        # Resqueで非同期的に画像解析を行う
          # 始めに画像をダウンロードし、終わり次第ユーザに配信
        if image_id and (not user_id.nil?)
          self.class.generate_jobs(image_id, image_data[:src_url], false, target_word.class.name, target_word.id)
        end
#=end        
         # limitを越えるか、その日に投稿された画像でなくなるまで
        break if count >= limit || image_data[:posted_at].to_date != DateTime.now.to_date
      end
      { scraped: scraped, duplicates: duplicates, skipped: skipped, avg_time: avg_time / ((scraped+duplicates)*1.0) }
    
    end
=begin
    # キーワードによる抽出処理を行う
    # @param [TargetWord]
    def scrape_target_word(user_id, target_word, english=false)
      @limit = 10
      @logger.info "Extracting #{@limit} images from: #{ROOT_URL}"

      result = scrape_using_api(target_word, user_id, true, false, english)
      @logger.info "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, skipped: #{result[:skipped]}, avg_time: #{result[:avg_time]}"
    end

    # 対象のタグを持つPostの画像を抽出する
    # @param [String]
    # @param [Integer]
    # @param [Boolean]
    # @return [Hash] Scraping result
    def scrape_using_api(target_word, user_id=nil, validation=true, logging=false, english=false)
      @logger.debug "#{target_word.inspect}"
      if english
        query = Scrape.get_query_en(target_word, 'roman')
      else
        query = Scrape.get_query_en(target_word, '')
      end
      return if query.nil? or query.empty?
      @logger.info "query=#{query}"


      duplicates = 0
      skipped = 0
      scraped = 0
      avg_time = 0

      # Mecanizeによりクエリ検索結果のページを取得
      page = self.get_search_result(query)

      # タグ検索：@limitで指定された数だけ画像を取得(最高80枚=1ページの最大表示数)　→ src_urlを投げる for anipic
      return if page.search("span[class='img_block_big']").count == 0
      page.search("span[class='img_block_big']").each_with_index do |image, count|

          # 広告又はR18画像はスキップ
        if image.children.search('img').first.nil?
          skipped += 1
          next
        else
            # サーチ結果ページから、ソースページのURLを取得
         page_url = ROOT_URL + image.children.search('a').first.attributes['href'].value
        end

          # ソースページのパース
        xml = Nokogiri::XML(open(page_url))
          # ソースページから画像情報を取得してDBへ保存する
        start = Time.now

        image_data = self.get_data(xml, page_url)


        options = {
          validation: validation,
          large: false,
          verbose: false,
          resque: (not user_id.nil?)
        }
        tags = self.get_tags_original(xml)
        #@logger.debug tags.inspect

        # 保存に必要なものはimage_data, tags, validetion
        image_id = self.class.save_image(image_data, @logger, target_word, Scrape.get_tags(tags), options)

        duplicates += image_id ? 0 : 1
        scraped += 1 if image_id
        elapsed_time = Time.now - start
        avg_time += elapsed_time
        @logger.info "Scraped from #{image_data[:src_url]} in #{elapsed_time} sec" if logging and res

        # Resqueで非同期的に画像解析を行う
        # 始めに画像をダウンロードし、終わり次第ユーザに配信
        if image_id and (not user_id.nil?)
          self.class.generate_jobs(image_id, image_data[:src_url], false,
            target_word.class.name, target_word.id)
        end

        # @limit枚抽出したら終了
        break if (count+1 - skipped) >= @limit
      end

      { scraped: scraped, duplicates: duplicates, skipped: skipped, avg_time: avg_time / ((scraped+duplicates)*1.0) }
    end

    # Mechanizeにより検索結果を取得
    # @param [String]
    # @return [Mechanize] Mechanizeのインスタンスを初期化して返す
    def get_search_result(query)
      agent = Mechanize.new
      agent.ssl_version = 'SSLv3'
      page = agent.get(ROOT_URL)

      # login作業
      #page.forms[1]['login'] = 'xxx'
      #page.forms[1]['password'] = 'xxx'
      #page.forms[1].submit

      page.forms[2]['search_tag'] = query

      result = page.forms[2].submit
      #puts(page.forms[2]['search_tags'])
      return result
    end
    
    def self.get_time(time_string)
      # 整形
      time = time_string
      time.gsub!(/\n|\t| /,'')
      time_t = time.split(/\/|,| /)
      time_t[2] = "20" + time_t[2]

      if (time_t[3] =~ /PM/)
        time_t[3].gsub!(/PM/,'')
        h = time_t[3].split(':')[0]
        m = time_t[3].split(':')[1]

        hi = h.to_i + 12
        hi = 0 if hi==24
        time_t[3] = "#{hi}:#{m}"
      else
        time_t[3].gsub!(/AM/,'')
      end

      # UTCに変換
      time_t[2] + "/" + time_t[0] + "/" + time_t[1] + "/" + time_t[3]
    end
=end

    # htmlからタグを取得
    # @param [Nokogiri::HTML]
    # @return [Array::String]
    def get_tags_original(html)
      result = []
      
       # その他の取得
      html.css("div[id='content']").first.css("dt").each do |dt|
        if dt.content.gsub!(/\t|\n/,"") == "Tags" || dt.content.gsub!(/\t|\n/,"") == "Source" || dt.content.gsub!(/\t|\n/,"") == "Character" then
          tags = dt.next.next.gsub!(/\t|\n/,"").split("\"")
          tags.each do |tag|
            if tag != ""
              result << tag
            end
          end
        end
      end

      return result
    end

    # 画像１枚に関する情報をHashにして返す。
    # original_favorite_countの抽出にはVotesを利用
    # @param [Nokogiri::HTML]
    # @param [String]
    # @return [Hash]
    def get_data(html, id)
      # titleの取得
      title = "shushu:Image #" + id
      caption = title
      time = nil
      src_url = nil
      original_url = nil
      author = nil
      favorite_count = nil
      height = nil
      width = nil
       # その他の取得
      html.css("div[id='content']").first.css("dt").each do |dt|
        #puts dt.content.gsub(/\t|\n/,"")
        case dt.content.gsub(/\t|\n/,"")
        when "Submitted On:" then
          # posted_atの取得
          time = DateTime.parse(dt.next.next.content)
          
        when "Filename:" then
          # src_urlの取得
          src_url = ROOT_URL + "images/thumbs/#{dt.next.next.content.split(".").first}.jpeg"
          # original_urlの取得
          original_url = ROOT_URL + "images/#{dt.next.next.content}"
        when "Artist:" then
          # authorの取得
          author = dt.next.next.content.gsub!(/\t|\n|\/|\"/,"")
        
        when "Image Rating:" then
          # favorite_countの取得
          favorite_count = dt.next.next.content.gsub!(/\t|\n"/,"")
          if favorite_count == "N/A"
            favorite_count = 0
          else
            favorite_count = favorite_count.to_i
          end
        when "Dimensions:" then
          height = dt.next.next.content.split(" ").first.split("x").second.to_i
          width = dt.next.next.content.split(" ").first.split("x").first.to_i
        else
        end
      end

      hash = {
        title: title,
        caption: caption,
        page_url: ROOT_URL + "image/#{id}/",
        posted_at: time,
        original_view_count: nil,
        src_url: src_url,
        original_url: original_url,
        original_favorite_count: favorite_count,             # Image Rating
        site_name: 'shushu',
        module_name: 'Scrape::Shushu',
        artist: author,
        height: height,
        width: width,
        original_height: height,
        original_width: width,
      }

      return hash
    end

  end
end
