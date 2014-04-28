# -*- coding: utf-8 -*-
require 'tumblr_client'
require 'tumblr/tagged'
require 'securerandom'


# Tumblrから画像抽出する
module Scrape::Tumblr
  ROOT_URL = 'https://tumblr.com'

  def self.scrape
    limit   = 20                  # 取得するPostの上限数。APIの仕様で20postsが限度
    count = Image.count
    puts "Extracting: #{ROOT_URL}"

    TargetWord.all.each do |target_word|
      if target_word.enabled
        # Person.nameで検索（e.g. "鹿目まどか"）
        # personと関連していない場合は直接word属性を使う
        puts query = target_word.person ? target_word.person.name : target_word.word
        next if query.nil? or query.empty?

        self.scrape_with_keyword(query, limit)
      end
    end

    puts "Extracted: #{(Image.count - count).to_s}"
  end

  # キーワードによる抽出処理を行う
  def self.scrape_keyword(keyword)
    self.scrape_with_keyword(keyword, 10, false)
  end

  # 対象のタグを持つPostの画像を抽出する
  def self.scrape_with_keyword(keyword, limit, validation=true)
    client = self.get_client
    duplicates = 0
    skipped = 0

    # タグ検索：limitで指定された数だけ画像を取得
    client.tagged(keyword).each_with_index do |image, count|
      # 画像のみを対象とする
      if image['type'] != 'photo'
        skipped += 1
        next
      end

      # API responseから画像情報を取得してDBへ保存する
      start = Time.now
      image_data = Scrape::Tumblr.get_data(image)
      res = Scrape.save_image(image_data, [], validation)
      duplicates += res ? 0 : 1
      puts "Scraped from #{image_data[:src_url]} in #{Time.now - start} sec"

      # limit枚抽出、もしくは重複が出現し始めたら終了
      #break if duplicates >= 3
      break if count+1-skipped >= limit
    end
  end

  # 画像１枚に関する情報をHashにして返す
  def self.get_data(image)
    # favoritesを抽出するのは重い(1枚あたり0.5-1.0sec)ので今のところ回避
    {
      title: 'tumblr' + SecureRandom.random_number(10**14).to_s,
      caption: image['caption'],
      src_url: image['photos'].first['original_size']['url'],
      page_url: image['post_url'],
      posted_at: image['date'],
      views: nil,
      #favorites: self.get_favorites(image['post_url']),
      favorites: image['note_count'],# reblog+likesされた数の合計値。別々には取得不可
      site_name: 'tumblr',
      module_name: 'Scrape::Tumblr',
    }
  end

  def self.get_client
    Tumblr.configure do |config|
      config.consumer_key = CONFIG['tumblr_consumer_key']
      config.consumer_secret = CONFIG['tumblr_consumer_secret']
      #config.oauth_token = "access_token"
      #config.oauth_token_secret = "access_token_secret"
    end
    Tumblr::Client.new
  end

  # 直接HTMLを開いてlikes数を取得する。遅い
  def self.get_favorites(page_url)
    begin
      # show:likesを設定しているページのみget
      html = Nokogiri::HTML(open(page_url))
      likes = html.css("ol[class='notes']").first.content.to_s.scan(/ likes this/)
      suki = html.css("ol[class='notes']").first.content.to_s.scan(/「スキ!」/)
      return likes.count + suki.count
    rescue => e
      puts e
      return
    end
  end

  # @tag : Array of strings
  def self.get_tags(tags)
    tags.map do |tag|
      t = Tag.where(name: tag)
      t.empty? ? Tag.new(name: tag) : t.first
    end
  end

  # 統計情報(likes_count)を更新する
  def self.get_stats(page_url)
    client = self.get_client
    blog_name = page_url.match(/http:\/\/.*.tumblr.com/).to_s.gsub(/http:\/\//, '').gsub(/.tumblr.com/,'')
    puts id = page_url.match(/post\/.*\//).to_s.gsub(/post\//,'').gsub(/\//,'')
    posts = client.posts(blog_name)

    puts post = posts['posts'].find { |h| h['id'] == id.to_i }

    { views: nil, favorites: post ? post['note_count'] : nil }
  end
end
