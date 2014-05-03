# -*- coding: utf-8 -*-
require "twitter"
require 'securerandom'


# Twitterから2次画像を抽出する
module Scrape::Twitter
  # TwitterURL
  ROOT_URL = 'https://twitter.com'

  # 関数定義
  def self.scrape
    limit   = 1000        # 取得するツイートの上限数
    count = Image.count

    # 全ての登録済みのTargetWordに対して新着画像を取得する
    puts 'Extracting : ' + ROOT_URL
    TargetWord.all.each do |target_word|
      # Person.nameで検索（e.g. '鹿目まどか'）
      if target_word.enabled
        puts query = target_word.person ? target_word.person.name : target_word.word
        next if query.nil? or query.empty?

        self.scrape_with_keyword(query, limit)
      end
    end

    puts "Extracted: #{(Image.count-count).to_s}"
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
      self.get_contents(client, keyword, limit, validation)
    # リクエストが多すぎる場合の例外処理
    rescue Twitter::Error::TooManyRequests => error
      puts 'Too many requests to twitter'
      return
      #sleep error.rate_limit.reset_in
      #retry
    # 検索ワードでツイートを取得できなかった場合の例外処理
    rescue Twitter::Error::ClientError
      puts 'ツイートを取得できませんでした'
    end

  end

  def self.get_contents(client, keyword, limit, validation=true)
    skipped = 0
    duplicates = 0
    count = 0

    # limitで指定された数だけツイートを取得
    client.search("#{keyword} -rt", locale: 'ja', result_type: 'recent',
      include_entity: true).take(limit).each do |tweet|
      # API responseから画像情報を取得してDBへ保存する
      start = Time.now
      image_data = self.get_data(tweet)

      if image_data.count > 0
        image_data.each do |data|
          res = Scrape.save_image(data, self.get_tags(keyword), validation)
          duplicates += res ? 0 : 1
          count += 1 if res
          puts "Scraped from #{data[:src_url]} in #{Time.now - start} sec" if res
        end
      else
        skipped += 1
        next
      end

      # limit枚抽出、もしくは重複が出現し始めたら終了
      break if duplicates >= 3
      break if count+1-skipped >= limit
    end
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


  def self.get_tags(keyword)
    tag = Tag.where(name: keyword)
    [ (tag.empty? ? Tag.new(name: keyword) : tag.first) ]
  end

  def self.get_stats(client, page_url)
    id = page_url.match(/\/\d.*\d$/).to_s
    begin
      tweet = client.status(id)
    rescue => e                   # Twitter::Error::Forbidden:など
      puts e
      return {}
    end

    { views: tweet.retweet_count, favorites: tweet.favorite_count }
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
