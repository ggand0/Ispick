# coding: utf-8
require 'open-uri'

module Scrape::Nico

  # ニコ静RSS(非公式)
  RSS_URL = 'http://seiga.nicovideo.jp/rss/illust/new'
  TAG_SEARCH_URL = 'http://seiga.nicovideo.jp/api/tagslide/data'
  ROOT_URL = ''

  # @page : Mechanize::Page
  def self.is_adult(page)
    puts page
    puts page.at("meta[@property='og:site_name']")
    site_name = page.at("meta[@property='og:site_name']").attr('content')
    site_name == 'ニコニコ春画'
  end

  def self.get_contents(page_url, agent, title, validation=true)
    t0 = Time.now
    # 元ページを開く
    begin
      page = agent.get(page_url)
    rescue Exception => e
      # ログイン求められて失敗した時用
      puts e
      puts 'PAGE_URL:'
      puts page_url
      Rails.logger.info('Could not open the page.')
      return
    end

    # 春画画像なら抽出を断念する
    return if is_adult(page)

    # 画像のソースurlを探して格納
    src_url = page.at("meta[@property='og:image']").attr('content')
    puts src_url

    # 画像の文字情報を取得
    tags = self.get_tags(page)
    caption = page.at("meta[name='description']").attr('content')

    # 追加情報を取得
    info_elements = page.at("ul[@class='illust_count']")#.children()
    views = info_elements.css("li[class='view']").css("span[class='count_value']").first.content
    comments = info_elements.css("li[class='comment']").css("span[class='count_value']").first.content
    clips = info_elements.css("li[class='clip']").css("span[class='count_value']").first.content
    puts views.to_s+' '+comments.to_s+' '+clips.to_s

    posted_at_string = page.at("span[@class='created']").content#2014年03月27日 19:56
    year = posted_at_string.match(/\d{4}/).to_s.to_i
    month = posted_at_string.match(/\d\d月/).to_s.delete!('月').to_i
    day = posted_at_string.match(/\d\d日/).to_s.delete!('日').to_i
    time = posted_at_string.match(/\d\d:\d\d/).to_s
    hour = time.match(/\d\d:/).to_s.delete!(':').to_i
    min = time.match(/:\d\d/).to_s.delete!(':').to_i
    posted_at = Time.mktime(year, month, day, hour, min).in_time_zone('Asia/Tokyo').utc

    image_data = {
      title: title,
      caption: caption,
      src_url: src_url,
      page_url: page_url,
      views: views,
      favorites: clips,
      posted_at: posted_at,
      site_name: 'nicoseiga',
      module_name: 'Scrape::Nico',
    }
    puts (Time.now - t0).to_s + 'sec'
    # Imageモデル生成＆DB保存
    Scrape::save_image(image_data, tags, validation)
  end

  # delivered_images update用に、
  # ログインしてstats情報だけ返す関数
  def self.get_stats(page_url)
    agent = self.login()
    page = agent.get(page_url)

    info_elements = page.at("ul[@class='illust_count']")
    views = info_elements.css("li[class='view']").css("span[class='count_value']").first.content
    comments = info_elements.css("li[class='comment']").css("span[class='count_value']").first.content
    clips = info_elements.css("li[class='clip']").css("span[class='count_value']").first.content
    #puts views.to_s+' '+comments.to_s+' '+clips.to_s

    { views: views, favorites: clips}
  end

  def self.get_tags(page)
    tag_string = page.at("meta[@name='keywords']").attr('content')
    tags = tag_string.split(',')
    tags.map { |tag| Tag.new(name: tag) }
  end

  def self.login()
    agent = Mechanize.new
    agent.ssl_version = 'SSLv3'
    agent.post('https://secure.nicovideo.jp/secure/login?site=seiga',
      'mail' => CONFIG['nico_email'],'password' => CONFIG['nico_password'])
    agent
  end

  # ニコニコ静画。非公式RSSから新着イラストを抽出する
  def self.scrape_rss()
    agent = self.login()

    xml = Nokogiri::XML(open(RSS_URL))
    puts 'Extracting : ' + RSS_URL

    # itemタグ（イラスト）ごとに処理
    xml.css('item').map do |item|
      title = item.css('title').first.content
      self.get_contents(item.css('link').first.content, agent, title)
    end
  end

  def self.scrape_keyword(keyword)
    agent = self.login()
    limit = 10
    self.scrape_with_keyword(agent, keyword, limit, false)
  end

  # タグ検索バージョンをデフォルトで使う事にする
  def self.scrape()
    agent = self.login()
    limit = 50

    TargetWord.all.each do |target_word|
      if target_word.enabled
        #http://seiga.nicovideo.jp/api/tagslide/data?page=1&query=%E5%BC%A6%E5%B7%BB%E3%83%9E%E3%82%AD
        query = target_word.person ? target_word.person.name : target_word.word
        puts 'query=' + query
        self.scrape_with_keyword(agent, query, limit, true)
      end
    end
  end

  def self.scrape_with_keyword(agent, keyword, limit, validation)
    url = TAG_SEARCH_URL+'?page=1&query='+keyword
    puts 'Extracting ' + limit.to_s + 'images from: ' + url

    escaped = URI.escape(url)
    xml = agent.get(escaped)

    # http://seiga.nicovideo.jp/seiga/im3858537
    # imageタグ（イラスト）ごとに処理
    count = 0
    xml.search('image').map do |item|
      begin
        title = item.css('title').first.content
        page_url = 'http://seiga.nicovideo.jp/seiga/im'+item.css('id').first.content
        self.get_contents(page_url, agent, title, validation)

        count += 1
        break if count >= limit
      rescue
        # 検索結果が0の場合など
        next
      end
    end
    puts 'COUNT'+count.to_s
  end

end