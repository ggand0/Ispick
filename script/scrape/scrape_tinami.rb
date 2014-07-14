# -*- coding: utf-8 -*-
# coding: utf-8
require 'securerandom'


module Scrape::Tinami
  ROOT_URL = 'http://www.tinami.com'

  # 取得するPostの上限数。APIの仕様で20postsが限度
  # Scrape images from tinami. The latter two params are used for testing.
  # @param [Integer] min
  # @param [Boolean] whether it's called for debug or not
  # @param [Boolean] whether it's called for debug or not
  def self.scrape(interval=60, pid_debug=false, sleep_debug=false)
    limit = 20
    logger = Logger.new('log/scrape_tinami_cron.log')
    logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    Scrape.scrape_target_words('Scrape::Tinami', logger, limit, interval, pid_debug, sleep_debug)
  end


  # キーワードによる抽出処理を行う
  # @param [TargetWord]
  def self.scrape_target_word(target_word, logger, english=false)
    limit = 10
    logger.info "Extracting #{limit} images from: #{ROOT_URL}"

    result = self.scrape_using_api(target_word, limit, logger, true, false, english)
    logger.info "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, skipped: #{result[:skipped]}, avg_time: #{result[:avg_time]}"
  end

  def self.get_query(target_word, english)
    if english
      query = target_word.person.name_english if target_word.person
    else
      query = Scrape.get_query target_word
    end
    query
  end

  # 対象のタグを持つPostの画像を抽出する
  # @param [String]
  # @param [Integer]
  # @param [Boolean]
  # @return [Hash] Scraping result
  def self.scrape_using_api(target_word, limit, logger, validation=true, logging=false, english=false)
    query = self.get_query target_word, english
    return if query.nil? or query.empty?
    logger.info "query=#{query}"
    client = self.get_client
    duplicates = 0
    skipped = 0
    scraped = 0
    avg_time = 0

    # queryで検索, 新着順、イラスト・漫画(うまくできないため省略）、セーフサーチオン
    search = client.search(text: query, sort: 'new', safe: 1)

    # タグ検索：limitで指定された数だけ画像を取得　→ contentを投げる for tinami
    search.contents.content.each_with_index do |image, count|
      # サーチ結果のIDから詳細情報（content）の取得
      content = client.content(cont_id: image.id, dates: 1)
      # illustまたはmangaのみを抽出
      if content.content.type != 'illust' && content.content.type != 'manga' then
        skipped += 1
        next
      end
      
      # tagが一つの場合、String[1]ではなくStringが返ってくるため配列へ
      tags = content.content.tags.tag
      if(tags.class == String) then
          tags = [tags]
      end
      # API responseから画像情報を取得してDBへ保存する
      start = Time.now
      image_data = Scrape::Tinami.get_data(content,image.id)
      # 保存に必要なものはimage_data, tags, validetion
      image_id = Scrape.save_image(image_data, logger, self.get_tags(tags), validation, false, false, false)

      duplicates += image_id ? 0 : 1
      scraped += 1 if image_id
      elapsed_time = Time.now - start
      avg_time += elapsed_time
      logger.info "Scraped from #{image_data[:src_url]} in #{elapsed_time} sec" if logging and res

      # Resqueで非同期的に画像解析を行う
      # 始めに画像をダウンロードし、終わり次第ユーザに配信
      if image_id
        Scrape.generate_jobs(image_id, image_data[:src_url], false, target_word.class.name, target_word.id)
      end

      # limit枚抽出したら終了
      #break if duplicates >= 3 # 検討中
      break if (count+1 - skipped) >= limit
    end

    { scraped: scraped, duplicates: duplicates, skipped: skipped, avg_time: avg_time / ((scraped+duplicates)*1.0) }
  end

  # 画像１枚に関する情報をHashにして返す。
  # favoritesの抽出には総閲覧数を利用
  # @param [Hash]
  # @return [Hash]
  def self.get_data(content,id)
    hash = {
    
      title: content.content.title,   
      caption: content.content.description,
      page_url: 'http://www.tinami.com/view/'+id.to_s,
      posted_at: content.content.dates.posted,
      views: nil,
      src_url: nil,

      #favorites: self.get_favorites(image['post_url']),
      # reblog+likesされた数の合計値。別々には取得不可
      favorites: content.content.total_view,

      site_name: 'tinami',
      module_name: 'Scrape::Tinami',
      }

   
      # image URLの取得(illust, manga)
      if(content.content.type == 'illust') then
        hash[:src_url] = content.content.image.url
      else
        hash[:src_url] = content.content.images.image.first.url
      end 
   
      return hash

  end

  # @return [Tinami::Client] APIキーを設定したClientオブジェクト
  def self.get_client
    TINAMI.configure do |config|
      config.api_key = CONFIG['tinami_consumer_key']
    end
    # loginは特に必要ない
    auth = TINAMI.auth(CONFIG['tinami_username'], CONFIG['tinami_password'])
    auth_key = auth.auth_key
    # TINAMI.new ではなく TINAMI.client
    client = TINAMI.client(auth_key: auth_key)

    return client
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
      logger.info e
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
  # @param [Tinami::Client]
  # @param [String]
  # @return [Hash]
  def self.get_stats(client, page_url)
    #client = self.get_client
    blog_name = page_url.match(/http:\/\/.*.tinami.com/).to_s.gsub(/http:\/\//, '').gsub(/.tinami.com/,'')
    id = page_url.match(/post\/.*\//).to_s.gsub(/post\//,'').gsub(/\//,'')
    posts = client.posts(blog_name)
    post = posts['posts'].find { |h| h['id'] == id.to_i } if posts['posts']

    { views: nil, favorites: post ? post['note_count'] : nil }
  end
end
