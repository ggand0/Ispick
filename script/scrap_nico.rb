
# coding: utf-8
require 'open-uri'

# ニコ静「まどかわいい」
#url = 'http://seiga.nicovideo.jp/api/tagslide/data?page=1&query=まどかわいい'
#url = 'http://seiga.nicovideo.jp/api/tagslide/data?page=1&query=%E3%81%BE%E3%81%A9%E3%81%8B%E3%82%8F%E3%81%84%E3%81%84'

# ニコ静RSS
url = 'http://seiga.nicovideo.jp/rss/illust/new'
xml = Nokogiri::XML(open(url))
puts url

items_css = xml.css("item").map do |e|
  page = e.css("link").first.content
  html = Nokogiri::HTML(open(page))

  main = html.css("table[id='illust_area'] tr td img").first
  img_url = main['src'].split('?')[0]
  root_img_url = URI.join(page_url,img_url).to_s

  image = Image.new(title: e.css("title").first.content)
  image.image_from_url root_img_url
  image.save!
end