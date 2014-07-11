# -*- coding: utf-8 -*-

# Giphyから画像抽出する
module Scrape
  class Giphy < Client
    ROOT_URL = 'http://giphy.com'

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
      scrape_target_words('Scrape::Giphy', interval)
    end

    # キーワードによる抽出処理を行う
    # @param target_word [TargetWord] 対象とするTargetWordオブジェクト
    def scrape_target_word(user_id, target_word)
      @limit = 10
      @logger.info "Extracting #{limit} images from: #{ROOT_URL}"

      result = self.scrape_using_api(target_word, user_id, true)
      @logger.info "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, skipped: #{result[:skipped]}, avg_time: #{result[:avg_time]}"
    end

    #
    # @param target_word [TargetWord] 対象のTargetWordオブジェクト
    def self.get_query(target_word)
      # 和名タグでのhitは期待出来ないので、
      # Person.name_englishで検索（e.g. "Madoka Kaname"）
      if target_word.person and not target_word.person.name_english.empty?
        return target_word.person.name_english
      else
        return nil
      end
    end

    # 対象のTargetWordからPostの画像を抽出する
    # @param target_word [TargetWord]
    # @param limit [Integer] 最大抽出枚数
    # @param validation [Boolean] validationを行うかどうか
    def scrape_using_api(target_word, user_id=nil, validation=true, verbose=false)
      query = self.class.get_query(target_word)
      return if query.nil? or query.empty?

      @logger.info "query=#{query}"
      client = self.class.get_client
      scraped = 0
      duplicates = 0
      skipped = 0
      avg_time = 0

      # タグ検索：limitで指定された数だけ画像を取得
      ::Giphy.search(query, { limit: @limit, offset: 0 }).each_with_index do |image, count|
        # API responseから画像情報を取得してDBへ保存する
        start = Time.now
        image_data = self.class.get_data(image)

        # タグは和名を使用
        image_id = save_image(image_data, [ Scrape.get_tag(target_word.word) ], validation, false, false, false)
        duplicates += image_id ? 0 : 1
        scraped += 1 if image_id
        elapsed_time = Time.now - start
        avg_time += elapsed_time
        @logger.info "Scraped from #{data[:src_url]} in #{Time.now - start} sec" if verbose and image_id

        # Resqueで非同期的に画像解析を行う
        # 始めに画像をダウンロードし、終わり次第ユーザに配信
        if image_id
          Scrape::Client.generate_jobs(image_id, image_data[:src_url], false, user_id, target_word.class.name, target_word.id)
        end

        break if duplicates >= 3
      end

      { scraped: scraped, duplicates: duplicates, skipped: skipped, avg_time: avg_time / ((scraped+duplicates)*1.0) }
    end

    # 画像１枚に関する情報をHashにして返す
    # @param image []
    def self.get_data(image)
      {
        title: 'giphy' + SecureRandom.random_number(10**14).to_s,
        caption: nil,
        src_url: image.original_image.url.to_s,
        page_url: image.url.to_s,
        posted_at: nil,
        views: nil,
        site_name: 'giphy',
        module_name: 'Scrape::Giphy',
      }
    end

    # GiphyクライアントをAPIキー情報を用いて初期化する
    def self.get_client
      ::Giphy::Configuration.configure do |config|
        #config.version = THE_API_VERSION
        config.api_key = 'dc6zaTOxFJmzC'  # public beta key
      end
    end

  end
end
