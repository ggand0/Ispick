# coding: utf-8
require 'open-uri'

module Scrape::Nico

  # ニコ静RSS(非公式)
  ROOT_URL = 'http://seiga.nicovideo.jp/rss/illust/new'

  def self.get_contents(item, agent)
    # 元ページを開く
    begin
      page_url = item.css('link').first.content
      page = agent.get(page_url)
    rescue Exception => e
      # ログイン求められて失敗した時用
      puts e
      Rails.logger.info('Image model saving failed.')
      return
    end

    # 画像のソースurlを探して格納
    src_url = page.at("meta[@property='og:image']").attr('content')
    puts src_url

    # 画像の文字情報を取得
    title = item.css('title').first.content
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
      view_nums: views,
      posted_time: posted_at,
      site_name: 'nicoimage'
    }

    # Imageモデル生成＆DB保存
    Scrape::save_image(image_data, tags)
  end

  def self.get_tags(page)
    tag_string = page.at("meta[@name='keywords']").attr('content')
    tags = tag_string.split(',')
    tags.map { |tag| Tag.new(name: tag) }
  end

  # ニコニコ静画。非公式RSSから新着イラストを抽出する
  def self.scrape()
    agent = Mechanize.new
    agent.ssl_version = 'SSLv3'
    agent.post('https://secure.nicovideo.jp/secure/login?site=seiga',
      'mail' => CONFIG['nico_email'],'password' => CONFIG['nico_password'])

    xml = Nokogiri::XML(open(ROOT_URL))
    puts 'Extracting : ' + ROOT_URL

    # itemタグ（イラスト）ごとに処理
    xml.css('item').map do |item|
      self.get_contents(item, agent)
    end
  end

end