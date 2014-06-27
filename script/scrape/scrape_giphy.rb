# -*- coding: utf-8 -*-

# Giphyから画像抽出する
module Scrape::Giphy
  ROOT_URL = 'http://giphy.com'

  # 取得するPostの上限数。APIの仕様で20postsが限度
  # Scrape images from twitter. The latter two params are used for testing.
  # @param [Integer] min
  # @param [Boolean] whether it's called for debug or not
  # @param [Boolean] whether it's called for debug or not
  def self.scrape(interval=60, pid_debug=false, sleep_debug=false)
    limit = 20
    Scrape.scrape_target_words('Scrape::Giphy', limit, interval, pid_debug, sleep_debug)
  end

  # キーワードによる抽出処理を行う
  # @param target_word [TargetWord] 対象とするTargetWordオブジェクト
  def self.scrape_target_word(target_word)
    limit = 10
    puts "Extracting #{limit} images from: #{ROOT_URL}"

    result = self.scrape_using_api(target_word, limit, true)
    puts "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, skipped: #{result[:skipped]}, avg_time: #{result[:avg_time]}"
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
  def self.scrape_using_api(target_word, limit, validation=true, logging=false)
    query = self.get_query(target_word)
    return if query.nil? or query.empty?

    client = self.get_client
    scraped = 0
    duplicates = 0
    skipped = 0
    avg_time = 0

    # タグ検索：limitで指定された数だけ画像を取得
    Giphy.search(query, { limit: limit, offset: 0 }).each_with_index do |image, count|
      # API responseから画像情報を取得してDBへ保存する
      start = Time.now
      image_data = self.get_data(image)

      # タグは和名を使用
      res = Scrape.save_image(image_data, [ self.get_tag(target_word.word) ], validation)
      duplicates += res ? 0 : 1
      scraped += 1 if res
      elapsed_time = Time.now - start
      avg_time += elapsed_time
      puts "Scraped from #{data[:src_url]} in #{Time.now - start} sec" if logging and res

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
    Giphy::Configuration.configure do |config|
      #config.version = THE_API_VERSION
      config.api_key = 'dc6zaTOxFJmzC'  # public beta key
    end
  end

  # @tag : Array of strings
  def self.get_tags(tags)
    tags.map do |tag|
      t = Tag.where(name: tag)
      t.empty? ? Tag.new(name: tag) : t.first
    end
  end

  # タグを取得する。DBに既にある場合はそのレコードを返す
  # @param [String]
  # @return [Tag] Tagオブジェクト
  def self.get_tag(tag)
    t = Tag.where(name: tag)
    t.empty? ? Tag.new(name: tag) : t.first
  end

end
