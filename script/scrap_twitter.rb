# -*- coding: utf-8 -*-
require "twitter"
require 'securerandom'


# 4chanから2次画像を抽出する
module Scrap::Twitter

    # TwitterURL
    ROOT_URL = 'https://twitter.com'

    # 関数定義
    def self.scrap()
        puts 'Extracting : ' + ROOT_URL

        # 変数
        limit   = 1000      # 取得するツイートの上限数
        keyword = "まどか"     # ハッシュタグによる検索を行う際のキーワード

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
            img_name = self.get_image_name(value)
            puts "#{img_name} : #{value}"
            if not Scrap::is_duplicate(value)
              Scrap::save_image(img_name, value)
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
                        image_url.push(value.media_uri.to_s)
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
