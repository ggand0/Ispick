# -*- coding: utf-8 -*-

# Giphyから画像抽出する
module Scrape::Giphy
  ROOT_URL = 'http://giphy.com'

  def self.scrape
    limit   = 20
    count = Image.count
    puts "Extracting: #{ROOT_URL}"

    TargetWord.all.each do |target_word|
      if target_word.enabled
        self.scrape_with_keyword(target_word, limit)
      end
    end

    puts "Extracted: #{(Image.count - count).to_s}"
  end

  # キーワードによる抽出処理を行う
  def self.scrape_keyword(keyword)
    self.scrape_with_keyword(keyword, 10, true)
  end

  def self.get_query(target_word)
    # 和名タグでのhitは期待出来ない
    # Person.name_englishで検索（e.g. "Madoka Kaname"）
    if target_word.person and not target_word.person.name_english.empty?
      return target_word.person.name_english
    else
      return nil
    end
  end

  # 対象のタグを持つPostの画像を抽出する
  def self.scrape_with_keyword(target_word, limit, validation=true)
    keyword = self.get_query(target_word)
    tag = target_word.person ? target_word.person.name : target_word.word
    client = self.get_client
    duplicates = 0
    skipped = 0

    # タグ検索：limitで指定された数だけ画像を取得
    Giphy.search(keyword, { limit: limit, offset: 0 }).each_with_index do |image, count|
      # API responseから画像情報を取得してDBへ保存する
      start = Time.now
      image_data = self.get_data(image)

      # タグは和名を使用
      res = Scrape.save_image(image_data, self.get_tag(tag), validation)
      duplicates += res ? 0 : 1
      puts "Scraped from #{image_data[:src_url]} in #{Time.now - start} sec" if res

      break if duplicates >= 3
    end
  end

  # 画像１枚に関する情報をHashにして返す
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
  def self.get_tag(keyword)
    tag = Tag.where(name: keyword)
    [ (tag.empty? ? Tag.new(name: keyword) : tag.first) ]
  end

end
