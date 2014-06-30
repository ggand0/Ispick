# -*- coding: utf-8 -*-
require "twitter"
require 'securerandom'


module Scrape::Twitter
  ROOT_URL = 'https://twitter.com'

  # 取得するPostの上限数。APIの仕様で20postsが限度
  # Scrape images from twitter. The latter two params are used for testing.
  # @param [Integer] min
  # @param [Boolean] whether it's called for debug or not
  # @param [Boolean] whether it's called for debug or not
  def self.scrape(interval=60, pid_debug=false, sleep_debug=false)
    limit = 1000
    logger = Logger.new('log/scrape_twitter_cron.log')
    logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    Scrape.scrape_target_words('Scrape::Twitter', logger, limit, interval, pid_debug, sleep_debug)
  end


  # キーワードによる抽出処理を行う
  # @param [TargetWord]
  def self.scrape_target_word(target_word, logger)
    limit = 200
    logger = Logger.new('log/scrape_twitter_cron.log')
    logger.info "Extracting #{limit} images from: #{ROOT_URL}"

    result = self.scrape_using_api(target_word, limit, true)
    logger.info "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, skipped: #{result[:skipped]}, avg_time: #{result[:avg_time]}"
  end

  # 対象のハッシュタグを持つツイートの画像を抽出する
  # @oaran [String]
  # @param [Integer]
  # @param [Boolean]
  def self.scrape_using_api(target_word, limit, logger, validation=true)
    client = self.get_client


    # キーワードを含むハッシュタグの検索
    begin
      self.get_contents(client, target_word, limit, logger, validation)

    # リクエストが多すぎる場合は待機する
    rescue Twitter::Error::TooManyRequests => error
      logger.info 'Too many requests to twitter'
      logger.info error
      logger.info error.rate_limit
      logger.info "Retrying in: #{error.rate_limit.reset_in}"
      sleep error.rate_limit.reset_in
      retry

    # 検索ワードでツイートを取得できなかった場合
    rescue Twitter::Error::ClientError
      logger.info 'ツイートを取得できませんでした'
    end
  end


  # # API responseから画像情報を取得してDBへ保存する
  # @param [Twitter::REST::Client]
  # @oaran [String]
  # @param [Integer]
  # @param [Boolean]
  def self.get_contents(client, target_word, limit, logger, validation=true, logging=false)
    query = Scrape.get_query target_word
    logger.info "query=#{query}"
    scraped = 0
    skipped = 0
    duplicates = 0
    avg_time = 0

    # limitで指定された数だけツイートを取得
    client.search("#{query} -rt", locale: 'ja', result_type: 'recent',
      include_entity: true).take(limit).each do |tweet|
      start = Time.now
      image_data = self.get_data(tweet)

      if image_data.count > 0
        image_data.each do |data|
          image_id = Scrape.save_image(data, logger, [ self.get_tag(query) ], validation, false, false, false)
          duplicates += image_id ? 0 : 1
          scraped += 1 if image_id
          elapsed_time = Time.now - start
          avg_time += elapsed_time
          logger.info "Scraped from #{data[:src_url]} in #{Time.now - start} sec" if logging and image_id

          # Resqueで非同期的に画像解析を行う
          # 始めに画像をダウンロードし、終わり次第ユーザに配信
          if image_id
            Scrape.generate_jobs(image_id, data[:src_url], false, target_word.class.name, target_word.id)
          end
        end
      else
        skipped += 1
        next
      end

      # limit枚抽出、もしくは重複が出現し始めたら終了
      break if duplicates >= 3
      break if scraped+1-skipped >= limit
    end

    { scraped: scraped, duplicates: duplicates, skipped: skipped, avg_time: avg_time / ((scraped+duplicates)*1.0) }
  end

  # TwitterのClientオブジェクトを取得する
  # @return [Twitter::REST::Client]
  def self.get_client
    client = Twitter::REST::Client.new do |config|
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

  # Tagオブジェクトの配列を取得する
  # @param [String]
  # @return [Array]
  def self.get_tags(tag)
    tag = Tag.where(name: tag)
    logger.info tag.empty?
    logger.info (tag.empty? ? Tag.new(name: tag) : tag.first).name
    [ (tag.empty? ? Tag.new(name: tag) : tag.first) ]
  end

  # タグを取得する。DBに既にある場合はそのレコードを返す
  # @param [String]
  def self.get_tag(tag)
    t = Tag.where(name: tag)
    t.empty? ? Tag.new(name: tag) : t.first
  end

  # 統計情報を取得する
  # @param []
  # @param [String]
  # @return [Hash]
  def self.get_stats(client, page_url)
    id = page_url.match(/\/\d.*\d$/).to_s
    begin
      tweet = client.status(id)
    rescue => e
      # Twitter::Error::Forbidden:など
      logger.info e
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
