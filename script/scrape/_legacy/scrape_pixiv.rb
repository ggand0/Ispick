# coding: utf-8
require 'open-uri'
require 'net/http'
require 'uri'

# PixivはRSSもAPIも無く、非常に抽出しにくい
module Scrape::Pixiv
  # タグ：まどかわいい
  ROOT_URL = "http://spapi.pixiv.net/iphone/search.php?s_mode=s_tag&word=%E3%81%BE%E3%81%A9%E3%81%8B%E3%82%8F%E3%81%84%E3%81%84&PHPSESSID=0"

  def self.get_contents(row)
    items = row.split(',')
    illust_id = items[0]
    illust_id = illust_id.gsub(/[^0-9A-Za-z]/, '')  # double quoteを除外
    title = items[3].force_encoding("UTF-8")        # encode()ではエラー
    caption = items[18].force_encoding("UTF-8")
    thumbnail = items[6].force_encoding("UTF-8")
    thumbnail = thumbnail.gsub("\"", '')
    img_url = thumbnail
    puts img_url

    # Imageモデル生成＆DB保存
    image_data = {
      title: title.encode('UTF-8'),
      caption: caption,
      src_url: img_url
    }
    logger = Logger.new('log/scrape_pixiv_cron.log')
    Scrape::Client.save_image(image_data, logger)
  end

  # 返ってきた文字列から割と強引に抽出する
  def self.scrape
    uri = URI.parse(ROOT_URL)
    result = Net::HTTP.get(uri)

    # まず、イラスト別に分けて配列に格納
    lines = result.split("\n")

    # 続いて各情報別に配列へ格納
    # index=0がイラストIDらしい
    # i=3:title, i=5:author, i=8:datetime, i=9 tags(スペース区切り),
    # i=18 caption, i=6: thumbnail
    for row in lines
      self.get_contents(row)
    end
  end

end