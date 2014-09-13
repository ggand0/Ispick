# coding: utf-8
require 'open-uri'

page_url = 'http://dic.nicovideo.jp'

# ニコ百「鹿目まどか」
url = 'http://dic.nicovideo.jp/a/%E9%B9%BF%E7%9B%AE%E3%81%BE%E3%81%A9%E3%81%8B'
html = Nokogiri::HTML(open(url))
puts url

# imgタグを全て選択/抽出する
html.css('img').each do |item|
  # srcフィールドにあるurlを抽出
  img_url = item['src'].split('?')[0]
  root_img_url = URI.join(page_url,img_url).to_s
  puts item['title']

  # 抽出情報からImageモデルを生成
  Scrap::save_image(item['title'], root_img_url)
end