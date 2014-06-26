# -*- coding: utf-8 -*-
require 'tumblr_client'
require 'tumblr/tagged'
# coding: utf-8
require 'securerandom'


module Scrape::Tumblr
  ROOT_URL = 'https://tumblr.com'

  # 取得するPostの上限数。APIの仕様で20postsが限度
  # Scrape images from tumblr. The latter two params are used for testing.
  # @param [Integer] min
  # @param [Boolean] whether it's called for debug or not
  # @param [Boolean] whether it's called for debug or not
  def self.scrape(interval=60, pid_debug=false, sleep_debug=false)
    limit = 20
    Scrape.scrape_target_words('Scrape::Tumblr', limit, interval, pid_debug, sleep_debug)
  end


  # キーワードによる抽出処理を行う
  # @param [TargetWord]
  def self.scrape_target_word(target_word)
    query = Scrape.get_query target_word
    limit = 10
    puts "Extracting #{limit} images from: #{ROOT_URL}"

    result = self.scrape_using_api(query, limit, true)
    puts "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, skipped: #{result[:skipped]}, avg_time: #{result[:avg_time]}"
  end

  # 対象のタグを持つPostの画像を抽出する
  # @param [String]
  # @param [Integer]
  # @param [Boolean]
  # @return [Hash] Scraping result
  def self.scrape_using_api(query, limit, validation=true, logging=false)
    client = self.get_client
    duplicates = 0
    skipped = 0
    scraped = 0
    avg_time = 0

    # タグ検索：limitで指定された数だけ画像を取得
    client.tagged(query).each_with_index do |image, count|
      # 画像のみを対象とする
      if image['type'] != 'photo'
        skipped += 1
        next
      end

      # API responseから画像情報を取得してDBへ保存する
      start = Time.now
      image_data = Scrape::Tumblr.get_data(image)
      res = Scrape.save_image(image_data, self.get_tags(image['tags']), validation)

      duplicates += res ? 0 : 1
      scraped += 1 if res
      elapsed_time = Time.now - start
      avg_time += elapsed_time
      puts "Scraped from #{image_data[:src_url]} in #{elapsed_time} sec" if logging and res

      # limit枚抽出したら終了
      #break if duplicates >= 3 # 検討中
      break if (count+1 - skipped) >= limit
    end

    { scraped: scraped, duplicates: duplicates, skipped: skipped, avg_time: avg_time / (scraped+duplicates)*1.0 }
  end

  # 画像１枚に関する情報をHashにして返す。
  # favoritesを抽出するのは重い(1枚あたり0.5-1.0sec)ので今のところ回避している。
  # @param [Hash]
  # @return [Hash]
  def self.get_data(image)
    {
      title: 'tumblr' + SecureRandom.random_number(10**14).to_s,
      caption: image['caption'],
      src_url: image['photos'].first['original_size']['url'],
      page_url: image['post_url'],
      posted_at: image['date'],
      views: nil,

      #favorites: self.get_favorites(image['post_url']),
      # reblog+likesされた数の合計値。別々には取得不可
      favorites: image['note_count'],

      site_name: 'tumblr',
      module_name: 'Scrape::Tumblr',
    }
  end

  # @return [Tumblr::Client] APIキーを設定したClientオブジェクト
  def self.get_client
    Tumblr.configure do |config|
      config.consumer_key = CONFIG['tumblr_consumer_key']
      config.consumer_secret = CONFIG['tumblr_consumer_secret']
    end
    Tumblr::Client.new
  end

  # 直接HTMLを開いてlikes数を取得する。パフォーマンスに問題あり
  # @param [String] likes_countを取得するページのurl
  def self.get_favorites(page_url)
    begin
      # show:likesを設定しているページのみ取得
      html = Nokogiri::HTML(open(page_url))
      likes = html.css("ol[class='notes']").first.content.to_s.scan(/ likes this/)
      suki = html.css("ol[class='notes']").first.content.to_s.scan(/「スキ!」/)
      return likes.count + suki.count
    rescue => e
      puts e
    end
  end

  # Tagインスタンスの配列を作成する
  # @param [Array] タグを表す文字列の配列
  # @return [Array] Tagオブジェクトの配列
  def self.get_tags(tags)
    tags.map do |tag|
      t = Tag.where(name: tag)
      t.empty? ? Tag.new(name: tag) : t.first
    end
  end

  # likes_countを更新する
  # @param [Tumblr::Client]
  # @param [String]
  # @return [Hash]
  def self.get_stats(client, page_url)
    #client = self.get_client
    blog_name = page_url.match(/http:\/\/.*.tumblr.com/).to_s.gsub(/http:\/\//, '').gsub(/.tumblr.com/,'')
    id = page_url.match(/post\/.*\//).to_s.gsub(/post\//,'').gsub(/\//,'')
    posts = client.posts(blog_name)
    post = posts['posts'].find { |h| h['id'] == id.to_i } if posts['posts']

    { views: nil, favorites: post ? post['note_count'] : nil }
  end
end
