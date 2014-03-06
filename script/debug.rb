# coding: utf-8
require 'open-uri'


# モジュール化する前の実験用として使用している
#ROOT_URL = 'http://backend.deviantart.com/rss.xml?type=deviation&q=boost%3Apopular+max_age%3A24h+in%3Amanga%2Fdigital+anime'
ROOT_URL = ''

xml = Nokogiri::XML(open(ROOT_URL))
puts 'Extracting : ' + ROOT_URL

items_css = xml.css("item").map do |e|
  page = e.css("link").first.content
  #page = 'http://ecchi-enzo.deviantart.com/art/Top-Heavy-ft-Sui-Feng-FREE-435076127'# mature content debug
  html = Nokogiri::HTML(open(page))

  mature = html.css("div[class='dev-content-mature mzone-main']").first
  #puts mature.nil?
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