#-*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'kconv'


# 2ちゃんねるから2次画像を抽出する
module Scrape::Nichan

  # 2ちゃんねるURL
  ROOT_URL = 'http://2ch.net/'

  # 関数定義
  def self.scrape()
    puts 'Extracting : ' + ROOT_URL

    # 2ちゃんねるのベースURL
    base_url = 'http://toro.2ch.net/illustrator/'    # イラストレータ板

    # 2ちゃんねるのスレッドのdatファイルURLを取得する
    limit = 5
    thread_dats = self.get_dat_url(base_url, limit)    # ハッシュ

    # 画像URLを取得する
    img_url_array = []    # 空の配列
    puts thread_dats.class
    puts thread_dats[:title]
    thread_dats[:url].each do |url|
      # datファイルの内容を文字列として取得
      dat_text = Nokogiri::HTML(open(url)).to_s
      str = "㎡"
      dat_text.delete!(str)   # 環境依存文字を除外
      img_url_array += self.get_img_url(dat_text)
    end

    # URLの重複をなくす
    img_url_array.uniq!

    # URLの配列について処理
    # zipで2配列をiterateする：http://goo.gl/6ikMRg
    img_url_array.zip(thread_dats[:title]).each do |url, title|
      img_title = self.get_image_name(url)      # 画像のタイトルを決定
      printf("%s : %s\n", title, url)           # 出力テスト

      #Scrape::save_image(img_title, url)        # Imageモデル生成＆DB保存
      Scrape::save_image(title, url)            # Imageモデル生成＆DB保存
    end
  end

  # スレッドのdatファイルへのURLを新着順に取得し、配列で返す関数
  def self.get_dat_url(base_url, limit)
    # subject.txtのURL
    subject_url = base_url + 'subject.txt'

    # スレッドのURLを取得
    thread_dat_url = []    # 空の配列
    thread_dat_title = []
    open(subject_url) do |con|
      con.each do |line|
        # datファイルのURLを配列に追加
        if /^(.*\.dat)/ =~ line then        # 正規表現にその行がマッチすれば
          dat_url = base_url + 'dat/' + $1  # マッチした文字列をurlに使用
          thread_dat_url.push(dat_url)

          # "xxx.dat<>"後の文字列がタイトルであると見越して取得
          thread_title = line.match(/.*dat<>/).post_match
          thread_dat_title.push(thread_title.toutf8)
        end

        return { url: thread_dat_url, title: thread_dat_title } if thread_dat_url.size >= limit
      end
    end

    { url: thread_dat_url, title: thread_dat_title }
  end

  # datファイルのテキストから画像のURLを取得し、配列で返す関数
  def self.get_img_url(text)
    img_url = []    # 空の配列
    #res_text = []

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
