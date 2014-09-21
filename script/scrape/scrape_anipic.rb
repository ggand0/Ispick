# -*- coding: utf-8 -*-
# coding: utf-8
require 'securerandom'
require "#{Rails.root}/script/scrape/client"


module Scrape
  class Anipic < Client
    ROOT_URL = 'http://anime-pictures.net'

    def initialize(logger=nil, limit=20)
      self.limit = limit
      if logger.nil?
        self.logger = Logger.new('log/scrape_anipic_cron.log')
      else
        self.logger = logger
      end
      self.logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    end

    # 取得するPostの上限数。APIの仕様で20postsが限度
    # Scrape images from anipic. The latter two params are used for testing.
    # @param [Integer] min
    # @param [Boolean] whether it's called for debug or not
    # @param [Boolean] whether it's called for debug or not
    def scrape(interval=60)
      @limit = 20
      @logger = Logger.new('log/scrape_anipic_cron.log')
      @logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
      scrape_target_words('Scrape::Anipic', interval)
    end

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

    # xmlからタグを取得
    # @param [Nokogiri::XML]
    # @return [Array::String]
    def get_tags_original(xml)
      result = []
      index = 0
      xml.css("ul[class='tags']").first.css('a').each do |a|
        result[index] = a.content
        index = index + 1
      end

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

    # 画像１枚に関する情報をHashにして返す。
    # favoritesの抽出にはVotesを利用
    # @param [Nokogiri::XML]
    # @param [String]
    # @return [Hash]
    def get_data(xml, page_url)
      # titleの取得
        # 改行の除去
      title = xml.css("div[class='post_content']").css("h1").first.content.gsub!(/\n/,'')
        # タブのスペースへの変換
      title.gsub!(/\t/,' ')
      # captionの取得
        # 改行の除去
      caption = xml.css('title').first.content.gsub!(/\n/,'')
        # タブのスペースへの変換
      caption.gsub!(/\t/,' ')

      # posted_atの取得( 8/13/14, 7:26 PM\n\t\t)
      time = xml.css("div[class='post_content']").css("b")[2].next.content
      time = self.class.get_time(time)
      time = Time.parse(time) 
      
      # src_urlの取得
      image_url_div = xml.css("div[id='big_preview_cont']")
      src_url = image_url_div.css("img").first.attributes['src'].value.gsub!(/ /,'')
      
      # original_urlの取得
      # aタグが上手くパース出来なかったときの例外処理
      if image_url_div.children.css("a").first.nil?
        original_url = ROOT_URL + xml.css("div[class='post_vote_block']").css("a[rel='nofollow']").first.attributes['href'].value.gsub!(/download_image/,"get_image")
      else
        original_url = ROOT_URL + image_url_div.children.search("a").first.attributes['href'].value
      end

      # votesの取得
      votes = xml.css("div[class='post_content']").first.css("b")[10].next_element.content
      hash = {
        title: title,
        caption: caption,
        page_url: page_url,
        posted_at: time,
        views: nil,
        src_url: src_url,
        original_url: original_url,
        favorites: votes,             # votesの数
        site_name: 'anipic',
        module_name: 'Scrape::Anipic',
      }

      return hash
    end

  end
end
