
# coding: utf-8
require 'open-uri'

page_url = 'http://dic.nicovideo.jp'

# ニコ百「鹿目まどか」
url = 'http://dic.nicovideo.jp/a/%E9%B9%BF%E7%9B%AE%E3%81%BE%E3%81%A9%E3%81%8B'
b = Nokogiri::HTML(open(url))
p url

b.css('img').each do |item|
    img_url = item['src'].split('?')[0]
    root_img_url = URI.join(page_url,img_url).to_s
    p item['title']

    image = Image.new(title: item['title'])
    image.image_from_url root_img_url
    image.save!
end