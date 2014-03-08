# coding: utf-8
require 'nokogiri'
require 'open-uri'
require 'kconv'


# ふたばちゃんねるから2次画像を抽出する
module Scrap::Futaba

  # ふたばちゃんねるURL
  ROOT_URL = 'http://www.2chan.net/'

  # 関数定義
  def self.scrap()
    puts 'Extracting : ' + ROOT_URL

    # 画像URLを取得する
    url = 'http://dat.2chan.net/img2/futaba.htm'
    html = Nokogiri::HTML(open(url))

    # 画像URLの配列
    img_url_array = []

    # aタグ内の画像URLを取得
    html.css("a[target='_blank']").each do |item|
      # 画像URL
      img_url = item['href']

      # 画像URLを取得
      if self.check_img_url(img_url) then
        img_url_array.push(img_url)
      end
    end

    # URLの重複をなくす
    img_url_array.uniq!

    # URLの配列について処理
    img_url_array.each do |value|
      # 画像のタイトルを決定
      img_title = ""
      if /^.+\/(.*)\..*$/ =~ value then
        img_title = "futaba_" + $1
      end

      # 出力テスト
      puts printf("%s : %s", img_title, value)

      # Imageモデル生成＆DB保存
      Scrap::save_image(img_title, value)
    end
  end


  # 画像のURLであることを確認する関数
  def self.check_img_url(img_url)
    # jpg, png, gif形式以外ならば除外する
    if !(/\.jpg$/i =~ img_url or /\.png$/i =~ img_url or /\.gif$/i =~ img_url) then
      return false
    end

    # サムネイル画像のURLを除外
    if /s\.(.*)$/ =~ img_url then
      return false
    end

    true
  end

end
