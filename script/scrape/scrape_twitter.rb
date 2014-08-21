# -*- coding: utf-8 -*-
require "twitter"
require 'securerandom'


module Scrape
  class Twitter < Client
    ROOT_URL = 'https://twitter.com'

    def initialize(logger=nil, limit=1000)
      self.limit = limit

      if logger.nil?
        self.logger = Logger.new('log/scrape_twitter_cron.log')
      else
        self.logger = logger
      end
      self.logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    end

    # Scrape images from nicoseiga. The latter two params are used for testing.
    # @param [Integer] min
    def scrape(interval=60)
      scrape_target_words('Scrape::Twitter', interval)
    end


    # キーワードによる抽出処理を行う
    # @param [TargetWord]
    def scrape_target_word(user_id, target_word)
      @limit = 200
      @logger.info "Extracting #{limit} images from: #{ROOT_URL}"

      result = self.scrape_using_api(target_word, user_id, true)
      @logger.info "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, skipped: #{result[:skipped]}, avg_time: #{result[:avg_time]}"
    end


    # 対象のハッシュタグを持つツイートの画像を抽出する
    # @oaran [String]
    # @param [Integer]
    # @param [Boolean]
    def scrape_using_api(target_word, user_id=nil, validation=true)
      # キーワードを含むハッシュタグの検索
      begin
        get_contents(target_word, user_id, validation)

      # リクエストが多すぎる場合は待機する
      rescue ::Twitter::Error::TooManyRequests => error
        @logger.info 'Too many requests to twitter'
        @logger.info error
        @logger.info error.rate_limit
        @logger.info "Retrying in: #{error.rate_limit.reset_in}"
        sleep error.rate_limit.reset_in
        retry

      # 検索ワードでツイートを取得できなかった場合
      rescue ::Twitter::Error::ClientError
        @logger.info 'ツイートを取得できませんでした'
      end
    end


    # # API responseから画像情報を取得してDBへ保存する
    # @param [Twitter::REST::Client]
    # @oaran [String]
    # @param [Integer]
    # @param [Boolean]
    def get_contents(target_word, user_id=nil, validation=true, verbose=false)
      query = Scrape.get_query(target_word)
      logger.info "query=#{query}"

      client = self.class.get_client
      scraped = 0
      skipped = 0
      duplicates = 0
      avg_time = 0

      # limitで指定された数だけツイートを取得
      client.search("#{query} -rt", locale: 'ja', result_type: 'recent',
        include_entity: true).take(@limit).each do |tweet|
        start = Time.now
        image_data = self.class.get_data(tweet)

        if image_data.count > 0
          options = {
            validation: validation,
            large: false,
            verbose: false,
            resque: (not user_id.nil?)
          }
          image_data.each do |data|
            image_id = self.class.save_image(data, @logger, target_word, [ Scrape.get_tag(query) ], options)
            duplicates += image_id ? 0 : 1
            scraped += 1 if image_id
            elapsed_time = Time.now - start
            avg_time += elapsed_time

            # Resqueで非同期的に画像解析を行う
            # 始めに画像をダウンロードし、終わり次第ユーザに配信
            if image_id and (not user_id.nil?)
              @logger.info "Scraped from #{data[:src_url]} in #{Time.now - start} sec" if verbose
              Scrape::Client.generate_jobs(image_id, data[:src_url], false, user_id, target_word.class.name, target_word.id)
            end
          end
        else
          skipped += 1
          next
        end

        # limit枚抽出、もしくは重複が出現し始めたら終了
        break if duplicates >= 3
        break if scraped+1-skipped >= @limit
      end

      { scraped: scraped, duplicates: duplicates, skipped: skipped, avg_time: avg_time / ((scraped+duplicates)*1.0) }
    end

    # TwitterのClientオブジェクトを取得する
    # @return [Twitter::REST::Client]
    def self.get_client
      client = ::Twitter::REST::Client.new do |config|
        config.consumer_key        = CONFIG['twitter_consumer_key']
        config.consumer_secret     = CONFIG['twitter_consumer_secret']
        config.access_token        = CONFIG['twitter_access_token']
        config.access_token_secret = CONFIG['twitter_access_token_secret']
      end
      client
    end


    # @param [Tweet] Tweetオブジェクト
    # @return [Hash]
    def self.get_data(tweet)
      image_data = []
      # entities内にメディア(画像等)を含む場合取得
      if tweet.media? then
        tweet.media.each do |value|
          url = value.media_uri.to_s
          image_data.push({
            title: self.get_image_name(url),
            src_url: url,
            caption: tweet.text,
            page_url: tweet.url.to_s,
            site_name: 'twitter',
            module_name: 'Scrape::Twitter',
            views: tweet.retweet_count,
            favorites: tweet.favorite_count,
            posted_at: tweet.created_at
          })
        end
      end
      image_data
    end


    # 統計情報を取得する
    # @param []
    # @param [String]
    # @return [Hash]
    def get_stats(page_url)
      client = self.class.get_client
      id = page_url.match(/\/\d.*\d$/).to_s
      begin
        tweet = client.status(id)
      rescue => e
        # Twitter::Error::Forbidden:など
        @logger.info e
        return {}
      end
      { views: tweet.retweet_count, favorites: tweet.favorite_count }
    end

    # 画像のタイトルを生成する
    # @param [String]
    # @return [String]
    def self.get_image_name(url)
      if /.+\/(.*)?\..*/ =~ url then
        image_name = "twitter_" + $1
        return image_name
      else
        # ランダムな14桁の数値を使用
        image_name = SecureRandom.random_number(10**14)
        return image_name
      end
    end

  end
end
