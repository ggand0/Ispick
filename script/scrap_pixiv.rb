# coding: utf-8
require 'open-uri'
require "#{Rails.root}/script/pixiv"
require 'net/http'
require 'uri'

# PixivはRSSもAPIも無く、非常に抽出しにくい
module Scrap::Pixiv
  # タグ：まどかわいい
  ROOT_URL = "http://spapi.pixiv.net/iphone/search.php?s_mode=s_tag&word=%E3%81%BE%E3%81%A9%E3%81%8B%E3%82%8F%E3%81%84%E3%81%84&PHPSESSID=0"

  def self.get_contents(row)
    items = row.split(",")
    illust_id = items[0]
    illust_id = illust_id.gsub(/[^0-9A-Za-z]/, '')  # double quoteを除外
    title = items[3].force_encoding("UTF-8")        # encode()ではエラー
    caption = items[18].force_encoding("UTF-8")
    thumbnail = items[6].force_encoding("UTF-8")
    thumbnail = thumbnail.gsub("\"", '')
    img_url = thumbnail
    puts img_url

    # Imageモデル生成＆DB保存
    if not Scrap::is_duplicate(img_url)
      Scrap::save_image(title.encode("UTF-8"), img_url, caption)
    else
      puts 'Skipping a duplicate image...'
    end
  end

  # 返ってきた文字列から割と強引に抽出する
  def self.scrap()
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