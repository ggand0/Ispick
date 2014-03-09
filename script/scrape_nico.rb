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

    # Imageモデル生成＆DB保存
    if not Scrape::is_duplicate(img_url)
      Scrape::save_image(item.css("title").first.content, img_url)
    else
      puts 'Skipping a duplicate image...'
    end
  end

  # ニコニコ静画。非公式RSSから新着イラストを抽出する
  def self.scrape()
    xml = Nokogiri::XML(open(ROOT_URL))
    puts 'Extracting : ' + ROOT_URL

    # itemタグ（イラスト）ごとに処理
    xml.css("item").map do |item|
      self.get_contents(item)
    end
  end

end