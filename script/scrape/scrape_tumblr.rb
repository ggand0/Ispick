# -*- coding: utf-8 -*-
require "#{Rails.root}/script/scrape/client"
require 'securerandom'
require 'tumblr_client'

module Scrape
  class Tumblr < Client
    ROOT_URL = 'https://tumblr.com'

    # @params logger [ActiveSupport::Logger] A logger object which is used during the process
    # @params limit [Integer] Max number of images to scrape
    def initialize(logger=nil, limit=20)
      self.limit = limit
      if logger.nil?
        self.logger = Logger.new('log/scrape_tumblr_cron.log')
      else
        self.logger = logger
      end
      self.logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    end


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
      result_hash = Scrape.get_result_hash
      if english
        query = Scrape.get_query_en(target_word, 'english')
      else
        query = Scrape.get_query_en(target_word, '')
      end
      if query.nil? or query.empty?
        result_hash[:info] = 'query was nil or empty'
        return result_hash
      end

      @logger.info "query=#{query}"
      client = self.class.get_client

      # タグ検索：limitで指定された数だけ画像を取得
      client.tagged(query).each_with_index do |image, count|
        # Scrape images only
        if image['type'] != 'photo'
          result_hash[:skipped] += 1
          next
        end

        # Retrieve data into a hash for creating a new Image record
        start = Time.now
        image_data = Scrape::Tumblr.get_data(image)
        options = Scrape.get_option_hash(validation, false, false, (not user_id.nil?))

        # Save images to the database using parent's class method
        image_id = self.class.save_image(image_data, @logger, target_word, Scrape.get_tags(image['tags']), options)

        # Update the statistics numbers
        result_hash[:duplicates] += image_id ? 0 : 1
        result_hash[:scraped] += 1 if image_id
        elapsed_time = Time.now - start
        result_hash[:avg_time] += elapsed_time


        # 登録直後の配信の場合は、ここでResqueで非同期的に画像解析を行う
        # 始めに画像をダウンロードし、終わり次第ユーザに配信
        if image_id and (not user_id.nil?)
          @logger.info "Scraped from #{image_data[:src_url]} in #{elapsed_time} sec" if verbose
          self.class.generate_jobs(image_id, 'Image', image_data[:src_url], false,
            user_id, target_word.class.name, target_word.id, @logger)
        end

        # Finish the loop after it scrapes @limit images
        break if (count+1 - result_hash[:skipped]) >= @limit
      end

      result_hash[:avg_time] = result_hash[:avg_time] / ((result_hash[:scraped]+result_hash[:duplicates])*1.0)
      result_hash
    end



    # ==============
    #  OLD METHODS
    # ==============
    # [OLD]直接HTMLを開いてlikes数を取得する。パフォーマンスに問題あり
    # @param [String] likes_countを取得するページのurl
    def get_original_favorite_count(page_url)
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

    def self.get_artist_information(caption)
        # タグの除去
      caption = caption.gsub(/<.*?>/,"")

      #Hatsune… Madoka? | hitsu [pixiv]
        #「まどかさん」/「かきあげ」のイラスト [pixiv]
        #「ハサハ」/「ローラ」の作品 [TINAMI] #illustail
      if /\[pixiv\]|\[TINAMI\]/ =~ caption
        /「.+」 *[\/|\|] *「(.+)」.+/ =~ caption
        if $1.nil?
          /.+ [\/|\|] (.+) \[.+\]/ =~ caption
          artist = $1
        else
          artist = $1
        end
      # Goddess of the Month August by 成瀬まひ
      elsif caption.scan(/ by /).size == 1
        /.+[by|By|BY] (.+)/ =~ caption
        artist = $1
      else
          artist = nil
      end

      return artist
    end


    # 画像１枚に関する情報をHashにして返す。
    # original_favorite_countを抽出するのは重い(1枚あたり0.5-1.0sec)ので今のところ回避している。
    # @param [Hash]
    # @return [Hash]
    def self.get_data(image)
      artist = self.get_artist_information(image['caption'])
      {
        artist: artist,
        poster: image['blog_name'],
        title: 'tumblr' + SecureRandom.random_number(10**14).to_s,
        caption: image['caption'],
        original_url: image['photos'].first['original_size']['url'],
        src_url: image['photos'].first['alt_sizes'][0]['url'],
        page_url: image['post_url'],
        posted_at: image['date'],
        original_width: image['photos'].first['original_size']['width'],
        original_height: image['photos'].first['original_size']['height'],
        original_view_count: nil,

        #original_favorite_count: self.get_original_favorite_count(image['post_url']),
        # reblog+likesされた数の合計値。別々には取得不可
        original_favorite_count: image['note_count'],

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

      { original_view_count: nil, original_favorite_count: post ? post['note_count'] : nil }
    end

  end
end
