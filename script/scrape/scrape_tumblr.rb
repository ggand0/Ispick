# -*- coding: utf-8 -*-
require 'tumblr_client'
require 'tumblr/tagged'
require 'securerandom'


# Tumblrから画像抽出する
module Scrape::Tumblr

  ROOT_URL = 'https://tumblr.com'

  # 関数定義
  def self.scrape()
    puts 'Extracting : ' + ROOT_URL

    limit   = 100        # 取得するPostの上限数
    count = Image.count

    # 全ての登録済みのTargetWordに対して新着画像を取得する
    # しかしながらTargetWord.count=10000とかになったら厳しいかも
    TargetWord.all.each do |target_word|
      # Person.nameで検索（e.g. "鹿目まどか"）
      # エイリアスも含めるならkeywords.eachする
      if target_word.enabled
        query = target_word.person ? target_word.person.name : target_word.word
        puts query
        self.scrape_with_keyword(query, limit)
      end
    end

    puts 'Scraped: '+(Image.count-count).to_s
  end

  def self.scrape_keyword(keyword)
    limit   = 10        # 取得するPostの上限数
    self.scrape_with_keyword(keyword, limit, false)
  end


  # 対象のハッシュタグを持つツイートの画像を抽出する
  def self.scrape_with_keyword(keyword, limit, validation=true)
    client = self.get_client

    # キーワードを含むハッシュタグの検索
    image_data = self.get_images(client, keyword, limit)

    self.save(image_data, validation)
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

  def self.get_favorites(html)
    likes = html.css("ol[class='notes']").first.content.to_s.scan(/likes this/)
    suki = html.css("ol[class='notes']").first.content.to_s.scan(/「スキ!」/)
    likes.count+suki.count
  end

  def self.get_contents(html, image)
    # show:likesを設定しているページのみgetしてみる
    likes = html.css("ol[class='notes']").first.content.to_s.scan(/likes this/)
    suki = html.css("ol[class='notes']").first.content.to_s.scan(/「スキ!」/)

    fav = likes.count+suki.count
    puts fav

    # photo以外だとここで落ちるはず
    hash = {
      title: 'tumblr' + SecureRandom.random_number(10**14).to_s,
      caption: image['caption'],
      src_url: image['photos'].first['original_size']['url'],
      page_url: image['post_url'],
      posted_at: image['date'],
      views: nil,
      favorites: fav,
      site_name: 'tumblr',
      module_name: 'Scrape::Tumblr',
    }
    tags = image['tags'].map { |tag| Tag.new(name: tag) }

    { data: hash, tags: tags }
  end

  def self.get_images(client, keyword, limit)
    image_data = []

    # limitで指定された数だけ画像を取得
    images = client.tagged(keyword)
    #images.each.take(limit) do |image|
    count=0
    images.each do |image|
      puts url = image['post_url']
      html = Nokogiri::HTML(open(url))
      begin
        image_data.push(self.get_contents(html, image))
      rescue => e
        # 非表示設定にしていてlikesが取れないページは諦める
        puts e
        next
      end
      count+=1
      break if count >= limit
    end
    image_data
  end


  def self.save(image_data, validation=true)
    # Imageモデル生成＆DB保存
    image_data.each do |value|
      puts "#{value[:data][:src_url]}"
      Scrape.save_image(value[:data], value[:tags], validation)
    end
  end

  def self.get_stats(page_url)
    html = Nokogiri::HTML(open(page_url))

    # 抽出してきた時点でlikes数が取れている画像のはずだが、一応rescue
    begin
      # show:likesを設定しているページのみgetしてみる
      #likes = html.css("ol[class='notes']").first.content.to_s.scan(/likes this/)
      likes = self.get_favorites(html)
    rescue => e
      # 非表示設定にしていてlikesが取れないページは諦める
      puts e
      Rails.logger.fail('Updating likes value has been failed: ' + page_url)
      return
    end

    puts page_url if not likes# debug
    { views: nil, favorites: likes }
  end

end
