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
      keywords = []
      if target_word.person.keywords
        target_word.person.keywords.each do |key|
          keywords.push(key.word) if key.is_alias
        end
      end
      keywords.uniq!

      # Person.nameで検索（e.g. "鹿目まどか"）
      # エイリアスも含めるならkeywords.eachする
      puts target_word.person.name
      self.scrape_with_keyword(target_word.person.name, limit)
    end

    puts 'Scraped: '+(Image.count-count).to_s
  end

  # 対象のハッシュタグを持つツイートの画像を抽出する
  def self.scrape_with_keyword(keyword, limit)
    # Twitter APIによるリクエスト
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = "OJof3PJIJTP9xCFmOD1w"
      config.consumer_secret     = "cSypo4EUdb8ZA3Rczo4YVgdhZ4IM7b7OhMN1RpBKc"
      config.access_token        = "875327030-hBjqCkLdBYmsjggmNS3rzdZKWuJ54QtzsHvkWFXP"
      config.access_token_secret = "Iyo7cwygF2Au2UgH5KDUEpG4pBpDWIeJ8EAFDOeUQ10rh"
    end

    # キーワードを含むハッシュタグの検索
    image_url = self.hash_tag_search(client, keyword, limit)

    # Imageモデル生成＆DB保存
    image_url.each do |value|
      img_name = self.get_image_name(value[:url])
      puts "#{img_name} : #{value[:url]}"
      if not Scrape::is_duplicate(value[:url])
        Scrape::save_image(img_name, value[:url], value[:caption], [ Tag.new(name: keyword) ])
      else
        puts 'Skipping a duplicate image...'
      end
    end
  end

  # ハッシュタグによる画像URL検索
  def self.hash_tag_search(client, keyword, limit)
    # 例外処理
    image_url = []
    begin
      # limitで指定された数だけツイートを取得
      client.search("#{keyword} -rt", :locale => "ja", :result_type => "recent", :include_entity => true).take(limit).map do |tweet|
        # entities内にメディア(画像等)を含む場合の処理
        if tweet.media? then
          tweet.media.each do |value|
            image_url.push({ url: value.media_uri.to_s, caption: tweet.text })
          end
        end
      end
    # 検索ワードでツイートを取得できなかった場合の例外処理
    rescue Twitter::Error::ClientError
      puts "ツイートを取得できませんでした"
    # リクエストが多すぎる場合の例外処理
    rescue Twitter::Error::TooManyRequests => error
      sleep error.rate_limit.reset_in
      retry
    end
    image_url   # Array
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
