#-*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'


# 2ちゃんねるから2次画像を抽出する
module Scrap::Nichan

  # 2ちゃんねるURL
  ROOT_URL = 'http://2ch.net/'

  # 関数定義
  def self.scrap()
    puts 'Extracting : ' + ROOT_URL

    # 2ちゃんねるのベースURL
    base_url = 'http://toro.2ch.net/illustrator/'    # イラストレータ板
    
    # 2ちゃんねるのスレッドのdatファイルURLを取得する
    limit = 5
    thread_dat_url = self.get_dat_url(base_url, limit)    # 配列

    # 画像URLを取得する
    img_url_array = []    # 空の配列
    thread_dat_url.each do |url|
      # datファイルの内容を文字列として取得
      dat_text = Nokogiri::HTML(open(url)).to_s
      str = "㎡"
      dat_text.delete!(str)   # 環境依存文字を除外
      img_url_array += self.get_img_url(dat_text)
    end

    # URLの重複をなくす
    img_url_array.uniq!

    # URLの配列について処理
    img_url_array.each do |value|
      img_title = self.get_image_name(value)      # 画像のタイトルを決定
      printf("%s : %s\n", img_title, value)       # 出力テスト
      Scrap::save_image(img_title, value)         # Imageモデル生成＆DB保存
    end

  end

  # スレッドのdatファイルへのURLを新着順に取得し、配列で返す関数
  def self.get_dat_url(base_url, limit)
    # subject.txtのURL 
    subject_url = base_url + 'subject.txt' 

    # スレッドのURLを取得
    thread_dat_url = []    # 空の配列
    open(subject_url) do |con|
      con.each do |line|
        # datファイルのURLを配列に追加
        if /^(.*\.dat)/ =~ line then
          dat_url = base_url + 'dat/' + $1
          thread_dat_url.push(dat_url)
        end
        return thread_dat_url if thread_dat_url.size >= limit
      end
    end
    thread_dat_url
  end

  # datファイルのテキストから画像のURLを取得し、配列で返す関数
  def self.get_img_url(text)
    img_url = []    # 空の配列
    # jpg, png, gif形式以外ならば除外する
    img_url += text.scan(/http:\/\/.*?\.jpg/i)
    img_url += text.scan(/http:\/\/.*?\.png/i)
    img_url += text.scan(/http:\/\/.*?\.gif/i)
    img_url
  end

  # 画像ファイルの名前を得る
  def self.get_image_name(url)
    if /^.+\/(.*)\..*$/ =~ url then
      img_title = "2ch_" + $1
      return img_title
    end
  end

end
