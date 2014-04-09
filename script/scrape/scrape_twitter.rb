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

    # 変数
    limit   = 1000        # 取得するツイートの上限数
    #keyword = "まどか"     # ハッシュタグによる検索を行う際のキーワード

    count = Image.count
    # 全ての登録済みのTargetWordに対して新着画像を取得する
    # しかしながらTargetWord.count=10000とかになったら厳しいかも
    TargetWord.all.each do |target_word|
      # Person.nameで検索（e.g. "鹿目まどか"）
      # エイリアスも含めるならkeywords.eachする
      puts target_word.person.name
      self.scrape_with_keyword(target_word.person.name, limit)
    end

    puts 'Scraped: '+(Image.count-count).to_s
  end

  # 対象のハッシュタグを持つツイートの画像を抽出する
  def self.scrape_with_keyword(keyword, limit)
    client = self.get_client

    # キーワードを含むハッシュタグの検索
    image_data = self.get_tweets(client, keyword, limit)

    self.save(image_data, keyword)
  end

  def self.get_client
    # Twitter APIによるリクエスト
    client = Twitter::REST::Client.new do |config|
=begin
      config.consumer_key        = "OJof3PJIJTP9xCFmOD1w"
      config.consumer_secret     = "cSypo4EUdb8ZA3Rczo4YVgdhZ4IM7b7OhMN1RpBKc"
      config.access_token        = "875327030-hBjqCkLdBYmsjggmNS3rzdZKWuJ54QtzsHvkWFXP"
      config.access_token_secret = "Iyo7cwygF2Au2UgH5KDUEpG4pBpDWIeJ8EAFDOeUQ10rh"
=end
      config.consumer_key        = CONFIG['twitter_consumer_key']
      config.consumer_secret     = CONFIG['twitter_consumer_secret']
    end
    client
  end

  def self.get_tweets(client, keyword, limit)
    image_data = []

    # limitで指定された数だけツイートを取得
    client.search("#{keyword} -rt", locale: 'ja', result_type: 'recent',
      include_entity: true).take(limit).map do |tweet|

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
    end
    image_data
  end

  def self.save(image_data, keyword)
    # Imageモデル生成＆DB保存
    image_data.each do |value|
      puts "#{value[:title]} : #{value[:src_url]}"
      if not Scrape::is_duplicate(value[:src_url])
        # attributes+tagsを渡す
        Scrape.save_image(value, [ Tag.new(name: keyword) ])
      else
        puts 'Skipping a duplicate image...'
      end
    end
  end

  def self.get_stats(page_url)
    client = self.get_client()
    id = page_url.match(/\/\d.*\d$/).to_s
    puts id
    puts id.gsub!(/\//, '')
    tweet = client.status(id)
    puts tweet.text

    { views: nil, favorites: tweet.favorite_count }
  end


  # ハッシュタグによる画像URL検索
  def self.hash_tag_search(client, keyword, limit)
    require 'twitter'
    # 例外処理
    begin
      return self.get_tweets(client, keyword, limit)
    # 検索ワードでツイートを取得できなかった場合の例外処理
    rescue Twitter::Error::ClientError
      puts "ツイートを取得できませんでした"
    # リクエストが多すぎる場合の例外処理
    rescue Twitter::Error::TooManyRequests => error
      sleep error.rate_limit.reset_in
      retry
    end
    #image_data   # Array
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
