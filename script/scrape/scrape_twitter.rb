# -*- coding: utf-8 -*-
require "twitter"
require 'securerandom'


# Twitterから2次画像を抽出する
module Scrape::Twitter
  # TwitterURL
  ROOT_URL = 'https://twitter.com'

  # 関数定義
  def self.scrape()
    puts 'Extracting : ' + ROOT_URL

    limit   = 1000        # 取得するツイートの上限数
    count = Image.count

    # 全ての登録済みのTargetWordに対して新着画像を取得する
    # TargetWord.count=10000とかになると厳しいか
    TargetWord.all.each do |target_word|
      # Person.nameで検索（e.g. '鹿目まどか'）
      if target_word.enabled
        puts query = target_word.person ? target_word.person.name : target_word.word
        next if query.nil? or query.empty?

        self.scrape_with_keyword(query, limit)
      end
    end

    puts 'Scraped: '+(Image.count-count).to_s
  end

  def self.scrape_keyword(keyword)
    limit   = 200        # 取得するツイートの上限数
    self.scrape_with_keyword(keyword, limit, false)
  end


  # 対象のハッシュタグを持つツイートの画像を抽出する
  def self.scrape_with_keyword(keyword, limit, validation=true)
    client = self.get_client

    # キーワードを含むハッシュタグの検索
    begin
      image_data = self.get_tweets(client, keyword, limit)
    # リクエストが多すぎる場合の例外処理
    rescue Twitter::Error::TooManyRequests => error
      #puts 'Too many requests to twitter'
      #sleep error.rate_limit.reset_in
      #retry
    # 検索ワードでツイートを取得できなかった場合の例外処理
    rescue Twitter::Error::ClientError
      puts 'ツイートを取得できませんでした'
    end

    self.save(image_data, keyword, validation)
  end

  def self.get_client
    # Twitter APIによるリクエスト
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = CONFIG['twitter_consumer_key']
      config.consumer_secret     = CONFIG['twitter_consumer_secret']
      config.access_token        = CONFIG['twitter_access_token']
      config.access_token_secret = CONFIG['twitter_access_token_secret']
    end
    client
  end

  def self.get_contents(tweet)
    image_data = []
    # entities内にメディア(画像等)を含む場合の処理
    if tweet.media? then      # v5.8.0
    #if tweet.entities? then  # v5.5.1
      tweet.media.each do |value|
        url = value.media_uri.to_s
        data = {
          title: self.get_image_name(url),
          src_url: url,
          caption: tweet.text,
          page_url: tweet.url.to_s,
          site_name: 'twitter',
          module_name: 'Scrape::Twitter',
          views: tweet.retweet_count,
          favorites: tweet.favorite_count,
          posted_at: tweet.created_at
        }
        image_data.push(data)
      end
    end
    image_data
  end

  def self.get_tweets(client, keyword, limit)
    image_data = []

    # limitで指定された数だけツイートを取得
    client.search("#{keyword} -rt", locale: 'ja', result_type: 'recent',
      include_entity: true).take(limit).map do |tweet|
      image_data += self.get_contents(tweet)
    end
    image_data
  end

  def self.save(image_data, keyword, validation=true)
    # Imageモデル生成＆DB保存
    image_data.each do |value|
      puts "#{value[:title]} : #{value[:src_url]}"

      if not Scrape::is_duplicate(value[:src_url])
        Scrape.save_image(value, self.get_tags(keyword), validation)
      else
        puts 'Skipping a duplicate image...'
      end
    end
  end

  def self.get_tags(keyword)
    tag = Tag.where(name: keyword)
    [ (tag.empty? ? Tag.new(name: keyword) : tag.first) ]
  end

  def self.get_stats(page_url)
    client = self.get_client()
    id = page_url.match(/\/\d.*\d$/).to_s
    begin
      tweet = client.status(id)
    rescue => e                   # Twitter::Error::Forbidden:など
      puts e
      return {}
    end

    { views: nil, favorites: tweet.favorite_count }
  end

  # 画像の名称を決定する
  def self.get_image_name(url)
    if /.+\/(.*)?\..*/ =~ url then
      image_name = "twitter_" + $1
      return image_name   # String
    else
      image_name = SecureRandom.random_number(10**14)  # ランダムな14桁の数値
      return image_name   # String
    end
  end

end
