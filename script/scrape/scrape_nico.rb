# coding: utf-8
require 'open-uri'


module Scrape::Nico
  RSS_URL = 'http://seiga.nicovideo.jp/rss/illust/new'
  TAG_SEARCH_URL = 'http://seiga.nicovideo.jp/api/tagslide/data'
  ROOT_URL = 'http://seiga.nicovideo.jp'

  # Scrape images from nicoseiga. The latter two params are used for testing.
  # @param [Integer] min
  # @param [Boolean] whether it's called for debug or not
  # @param [Boolean] whether it's called for debug or not
  def self.scrape(interval=60, pid_debug=false, sleep_debug=false)
    limit = 50
    logger = Logger.new('log/scrape_nico_cron.log')
    Scrape.scrape_target_words('Scrape::Nico', logger, limit, interval, pid_debug, sleep_debug)
  end


  # キーワードによる検索・抽出を行う
  # @param target_word[TargetWord]
  # @param logger [Logger] ログ出力に使用させたいloggerインスタンス
  def self.scrape_target_word(target_word, logger)
    query = Scrape.get_query target_word
    limit = 10
    logger.info "Extracting #{limit} images from: #{ROOT_URL}"

    result = self.scrape_using_api(query, limit, logger, true)
    logger.info "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, avg_time: #{result[:avg_time]}"
  end

  # キーワードからタグ検索してlimit分の画像を保存する
  # @param [String]
  # @param [Integer]
  # @param [Boolean]
  # @return [Hash]
  def self.scrape_using_api(query, limit, logger, validation=true, logging=false)
    # nilのクエリ弾く
    return if query.nil? or query.empty?

    agent = self.get_client
    url = "#{TAG_SEARCH_URL}?page=1&query=#{query}"
    escaped = URI.escape(url)
    xml = agent.get(escaped)
    duplicates = 0
    scraped = 0
    avg_time = 0

    # 画像情報を取得してlimit枚DBヘ保存する
    xml.search('image').take(limit).each_with_index do |item, count|
      begin
        next if item.css('adult_level').first.content.to_i > 0  # 春画画像をskip

        start = Time.now
        image_data = self.get_data(item)                        # APIの結果から画像情報取得
        saved = Scrape::save_image(image_data, logger, [ self.get_tag(query) ] , validation)

        duplicates += saved ? 0 : 1
        scraped += 1 if saved
        elapsed_time = Time.now - start
        avg_time += elapsed_time
        logger.info "Scraped from #{image_data[:src_url]} in #{elapsed_time} sec" if logging and res

        break if duplicates >= 3
      rescue => e
        # 検索結果が0の場合など
        logger.error e
        next
      end
      break if count+1 >= limit
    end

    { scraped: scraped, duplicates: duplicates, avg_time: avg_time / ((scraped+duplicates)*1.0) }
  end

  # Image modelのattributesを組み立てる
  # @param [Nokogiri::HTML]
  # @return [Hash]
  def self.get_data(item)
    {
      title: item.css('title').first.content,
      caption: item.css('description').first.content,
      src_url: "http://lohas.nicoseiga.jp/thumb/#{item.css('id').first.content}i",
      page_url: "http://seiga.nicovideo.jp/seiga/im#{item.css('id').first.content}",
      views: item.css('view_count').first.content,
      favorites: item.css('clip_count').first.content,
      # JSTの投稿日時が返却されるのでUTCに変換する
      posted_at: DateTime.parse(item.css('created').first.content).in_time_zone('Asia/Tokyo').utc,
      site_name: 'nicoseiga',
      module_name: 'Scrape::Nico',
    }
  end

  # page_urlから情報・画像抽出する
  # @param [String]
  # @param [Mechanize]
  # @param [Hash]
  # @param [Boolean]
  def self.get_contents(page_url, agent, image_data, validation=true)
    start = Time.now
    begin
      page = agent.get(page_url)  # 元ページを開く
    rescue Exception => e         # ログイン求められて失敗した場合など
      puts "Failed to open page_url: #{page_url}"
      puts e
      Rails.logger.info('Could not open a page.')
      return
    end

    # タグ情報を取得
    tag_string = page.at("meta[@name='keywords']").attr('content')
    tags = self.get_tags(tag_string.split(','))

    # Imageレコードをupdate
    #Scrape::save_image(hash.merge(image_data), tags, validation)

    puts "Updated in #{(Time.now - start).to_s} sec"
  end

  # Mechanizeによるログインを行う
  # @return [Mechanize] Mechanizeのインスタンスを初期化して返す
  def self.get_client
    agent = Mechanize.new
    agent.ssl_version = 'SSLv3'
    agent.post('https://secure.nicovideo.jp/secure/login?site=seiga',
      'mail' => CONFIG['nico_email'],'password' => CONFIG['nico_password'])
    agent
  end

  # タグを取得する。DBに既にある場合はそのレコードを返す
  # @param [String]
  def self.get_tag(tag)
    t = Tag.where(name: tag)
    t.empty? ? Tag.new(name: tag) : t.first
  end

  # タグを取得する。DBに既にある場合はそのレコードを返す
  # @param [Array]
  def self.get_tags(tags)
    tags.map do |tag|
      t = Tag.where(name: tag)
      t.empty? ? Tag.new(name: tag) : t.first
    end
  end

  # delivered_images update用に、
  # ログインしてstats情報だけ返す関数
  # @param [Mechanize]
  # @param [String]
  # @return [Hash]
  def self.get_stats(agent, page_url)
    begin
      page = agent.get(page_url)
      info_elements = page.at("ul[@class='illust_count']")
      views = info_elements.css("li[class='view']").css("span[class='count_value']").first.content
      comments = info_elements.css("li[class='comment']").css("span[class='count_value']").first.content
      clips = info_elements.css("li[class='clip']").css("span[class='count_value']").first.content
    rescue => e
      return false
    end

    { views: views, favorites: clips}
  end
end