# -*- coding: utf-8 -*-
require "#{Rails.root}/script/scrape/client"
require 'securerandom'
require 'tumblr_client'

module Scrape
  class Tumblr < Client
    ROOT_URL = 'https://tumblr.com'

    def initialize(logger=nil, limit=20)
      self.limit = limit
      if logger.nil?
        self.logger = Logger.new('log/scrape_tumblr_cron.log')
      else
        self.logger = logger
      end
      self.logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    end


    # 取得するPostの上限数。APIの仕様で20postsまでに制限されている
    # Scrape images from tumblr. The latter two params are used for testing.
    # @param [Integer] min
    def scrape(interval=60)
      scrape_target_words('Scrape::Tumblr', interval)
    end


    # キーワードによる抽出処理を行う
    # @param user_id [Integer]
    # @param target_word [TargetWord]
    # @param english [Boolean]
    def scrape_target_word(user_id, target_word, english=false)
      @limit = 10
      @logger.info "Extracting #{@limit} images from: #{ROOT_URL}"

      result = scrape_using_api(target_word, user_id, true, false, english)
      @logger.info "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, skipped: #{result[:skipped]}, avg_time: #{result[:avg_time]}"
    end


    # Scrape images that posess target_word
    # 対象のタグを持つPostの画像を抽出する
    # @param [String]
    # @param [Integer]
    # @param [Boolean]
    # @return [Hash] Scraping result
    def scrape_using_api(target_word, user_id=nil, validation=true, verbose=false, english=false)
      if english
        query = Scrape.get_query_en(target_word, 'english')
      else
        query = Scrape.get_query_en(target_word, '')
      end
      return if query.nil? or query.empty?

      @logger.info "query=#{query}"
      client = self.class.get_client
      duplicates = 0
      skipped = 0
      scraped = 0
      avg_time = 0

      # タグ検索：limitで指定された数だけ画像を取得
      client.tagged(query).each_with_index do |image, count|
        # 画像のみを対象とする
        if image['type'] != 'photo'
          skipped += 1
          next
        end


        # API responseから画像情報を取得してDBへ保存する
        start = Time.now
        image_data = Scrape::Tumblr.get_data(image)
        options = {
          validation: validation,
          large: false,
          verbose: false,
          resque: (not user_id.nil?)
        }

        # Save images to the database using parent's class method
        image_id = self.class.save_image(image_data, @logger, target_word, Scrape.get_tags(image['tags']), options)

        # 抽出情報の更新
        duplicates += image_id ? 0 : 1
        scraped += 1 if image_id
        elapsed_time = Time.now - start
        avg_time += elapsed_time


        # 登録直後の配信の場合は、ここでResqueで非同期的に画像解析を行う
        # 始めに画像をダウンロードし、終わり次第ユーザに配信
        if image_id and (not user_id.nil?)
          @logger.info "Scraped from #{image_data[:src_url]} in #{elapsed_time} sec" if verbose
          self.class.generate_jobs(image_id, image_data[:src_url], false,
            user_id, target_word.class.name, target_word.id, @logger)
        end

        # limit枚抽出したら終了
        #break if duplicates >= 3 # 検討中
        break if (count+1 - skipped) >= limit
      end

      { scraped: scraped, duplicates: duplicates, skipped: skipped, avg_time: avg_time / ((scraped+duplicates)*1.0) }
    end



    # ==============
    #  OLD METHODS
    # ==============
    # [OLD]直接HTMLを開いてlikes数を取得する。パフォーマンスに問題あり
    # @param [String] likes_countを取得するページのurl
    def get_favorites(page_url)
      begin
        # show:likesを設定しているページのみ取得
        html = Nokogiri::HTML(open(page_url))
        likes = html.css("ol[class='notes']").first.content.to_s.scan(/ likes this/)
        suki = html.css("ol[class='notes']").first.content.to_s.scan(/「スキ!」/)
        return likes.count + suki.count
      rescue => e
        @logger.info e
      end
    end


    # @return [Tumblr::Client] APIキーを設定したClientオブジェクト
    def self.get_client
      ::Tumblr.configure do |config|
        config.consumer_key = CONFIG['tumblr_consumer_key']
        config.consumer_secret = CONFIG['tumblr_consumer_secret']
      end
      ::Tumblr::Client.new
    end


    # 画像１枚に関する情報をHashにして返す。
    # favoritesを抽出するのは重い(1枚あたり0.5-1.0sec)ので今のところ回避している。
    # @param [Hash]
    # @return [Hash]
    def self.get_data(image)
      {
        author: nil,
        title: 'tumblr' + SecureRandom.random_number(10**14).to_s,
        caption: image['caption'],
        original_url: image['photos'].first['original_size']['url'],
        src_url: image['photos'].first['alt_sizes'][0]['url'],
        page_url: image['post_url'],
        posted_at: image['date'],
        views: nil,

        #favorites: self.get_favorites(image['post_url']),
        # reblog+likesされた数の合計値。別々には取得不可
        favorites: image['note_count'],

        site_name: 'tumblr',
        module_name: 'Scrape::Tumblr',
      }
    end


    # [OLD]likes_countを更新する
    # @param [String]
    # @return [Hash]
    def self.get_stats(page_url)
      puts 'DEBUG'
      client = self.get_client
      #client = self.class.get_client

      blog_name = page_url.match(/http:\/\/.*.tumblr.com/).to_s.gsub(/http:\/\//, '').gsub(/.tumblr.com/,'')
      id = page_url.match(/post\/.*\//).to_s.gsub(/post\//,'').gsub(/\//,'')
      posts = client.posts(blog_name)
      post = posts['posts'].find { |h| h['id'] == id.to_i } if posts['posts']

      { views: nil, favorites: post ? post['note_count'] : nil }
    end

  end
end
