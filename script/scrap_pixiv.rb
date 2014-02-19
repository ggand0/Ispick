# coding: utf-8
require 'open-uri'
require "#{Rails.root}/script/pixiv"
require 'net/http'
require 'uri'

module Scrap::Pixiv
  # タグ：まどかわいい
  ROOT_URL = "http://spapi.pixiv.net/iphone/search.php?s_mode=s_tag&word=%E3%81%BE%E3%81%A9%E3%81%8B%E3%82%8F%E3%81%84%E3%81%84&PHPSESSID=0"

  def self.scrap()
    img_urls = []
    uri = URI.parse(ROOT_URL)
    result = Net::HTTP.get(uri)
    lines = result.split("\n")

    # index=0がイラストIDらしい
    # i=3:title, i=5:author, i=8:datetime, i=9 tags(スペース区切り), i=18 caption
    # i=6: thumbnail
    for row in lines
      items = row.split(",")
      illust_id = items[0]
      illust_id = illust_id.gsub(/[^0-9A-Za-z]/, '')# ""除外
      title = items[3].force_encoding("UTF-8")
      caption = items[18].force_encoding("UTF-8")
      thumbnail = items[6].force_encoding("UTF-8")
      thumbnail = thumbnail.gsub("\"", '')
      img_url = thumbnail
      puts img_url

      image = Image.new(title: title.encode("UTF-8"), caption: caption)
      image.image_from_url img_url
      image.save!
    end
  end

end