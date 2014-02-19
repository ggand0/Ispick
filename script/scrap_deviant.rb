# coding: utf-8
require 'open-uri'

module Scrap::Deviant
  # Use official api
  # boost%3Apopular : 人気順
  # max_age%3A24h : 24時間以内のimage
  # in%3Amanga : mangaカテゴリ内のimage
  # 後は"deviantART rss api"とかでググれ！
  ROOT_URL = 'http://backend.deviantart.com/rss.xml?type=deviation&q=boost%3Apopular+max_age%3A24h+in%3Amanga%2Fdigital+anime'

  def self.scrap()
    xml = Nokogiri::XML(open(ROOT_URL))
    puts 'Extracting : ' + ROOT_URL

    items_css = xml.css("item").map do |e|
      page = e.css("link").first.content
      # mature content debug url
      #page = 'http://ecchi-enzo.deviantart.com/art/Top-Heavy-ft-Sui-Feng-FREE-435076127'
      html = Nokogiri::HTML(open(page))

      # mature画像はクリックをsimulateしないと抽出出来ないくさいので飛ばす
      mature = html.css("div[class='dev-content-mature mzone-main']").first
      if not mature.nil?
        next
      end

      main = html.css("img[class='dev-content-full']").first
      img_url = main['src']
      puts img_url

      image = Image.new(title: e.css("title").first.content)
      image.image_from_url img_url
      image.save!
    end
  end

end