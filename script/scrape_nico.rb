# coding: utf-8
require 'open-uri'

module Scrape::Nico

  # ニコ静RSS(非公式)
  ROOT_URL = 'http://seiga.nicovideo.jp/rss/illust/new'

  def self.get_contents(item)
    # 元ページを開く
    begin
      page = item.css('link').first.content
      html = Nokogiri::HTML(open(page))
    rescue Exception => e
      # ログイン求められて失敗した時用
      Rails.logger.info('Image model saving failed.')
      return
    end

    # 画像のソースurlを探して格納
    # id名が「illust_area」であるtableタグを探し、その中にあるタグをさらに降りていく
    main = html.css("table[id='illust_area'] tr td img").first
    img_url = main['src'].split('?')[0]
    puts img_url

    # 画像の文字情報を取得
    title = item.css('title').first.content
    tags = self.get_tags(html)
    caption = html.css("meta[name='description']").attr('content')

    # Imageモデル生成＆DB保存
    Scrape::save_image(title, img_url, caption, tags)
  end

  def self.get_tags(html)
    html.css("a[class='tag']").map { |tag| Tag.new(name: tag.content) }
  end

  # ニコニコ静画。非公式RSSから新着イラストを抽出する
  def self.scrape()
    xml = Nokogiri::XML(open(ROOT_URL))
    puts 'Extracting : ' + ROOT_URL

    # itemタグ（イラスト）ごとに処理
    xml.css('item').map do |item|
      self.get_contents(item)
    end
  end

end