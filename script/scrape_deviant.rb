# coding: utf-8
require 'open-uri'

# 公式APIを有するので色々調整出来そう
module Scrape::Deviant
  # Use official api
  # boost%3Apopular : 人気順
  # max_age%3A24h : 24時間以内のimage
  # in%3Amanga : mangaカテゴリ内のimage
  # 後はここを参照：http://b.hatena.ne.jp/pentiumx/deviantart/
  ROOT_URL = 'http://backend.deviantart.com/rss.xml?type=deviation&q=boost%3Apopular+max_age%3A24h+in%3Amanga%2Fdigital+anime'

  def self.is_adult(html)
    # アダルトな画像（"mature content"みたいに表現されてる）のデバッグ用url
    #page = 'http://ecchi-enzo.deviantart.com/art/Top-Heavy-ft-Sui-Feng-FREE-435076127'
    # mature画像はクリックをsimulateしないと抽出出来ないくさいので飛ばす
    mature = html.css("div[class='dev-content-mature mzone-main']").first
    if not mature.nil?
      return true
    end
    false
  end

  def self.get_contents(page, title)
    begin
      html = Nokogiri::HTML(open(page))
    rescue Exception => e
      Rails.logger.info('Image model saving failed.')
      return
    end

    if self.is_adult(html)
      return
    end

    # "dev-content-full"とdev-content-normal"で２種類画像ソースが用意されているようだ
    main = html.css("img[class='dev-content-full']").first
    img_url = main['src']
    puts img_url

    # Imageモデル生成＆DB保存
    Scrape::save_image(title, img_url)
  end

  def self.scrape()
    xml = Nokogiri::XML(open(ROOT_URL))
    puts 'Extracting : ' + ROOT_URL

    xml.css("item").map do |item|
      page = item.css("link").first.content
      self.get_contents(page, item.css("title").first.content)
    end
  end

end