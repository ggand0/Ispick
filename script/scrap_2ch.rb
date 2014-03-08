# coding: utf-8
require 'nokogiri'
require 'open-uri'
require 'kconv'


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
    thread_limit = 5
    thread_dat_array = self.get_dat_url(base_url, thread_limit)    # 配列

    # 画像URLを取得する
    img_url_array = []    # 空の配列
    thread_dat_array.each do |value|
       dat_text = ""    # 空文字列

       # datファイルの内容を文字列として取得
       open(value) do |con|
         con.each do |line|
           dat_text += line.toutf8
         end
       end

       img_url_array += self.get_img_url(dat_text)
    end

    # URLの重複をなくす
    img_url_array.uniq!

    # URLの配列について処理
    img_url_array.each do |value|
      # 画像のタイトルを決定
      img_title = ""
      if /^.+\/(.*)\..*$/ =~ value then
        img_title = "2ch_" + $1
      end
      
      # 出力テスト
      puts printf("%s : %s", img_title, value)

      # Imageモデル生成＆DB保存
      Scrap::save_image(img_title, value)
    end
  end


  # スレッドのdatファイルへのURLを新着順に取得し、配列で返す関数
  def self.get_dat_url(base_url, thread_limit)
    thread_dat_url = []    # 空の配列

    # subject.txtを取得する
    subject_url = base_url + 'subject.txt'    # スレッド一覧を取得
    open(subject_url) do |con|
      con.each do |line|
        tmp = line.toutf8    # utf-8に変換

        # datファイルのURLを配列に追加
        if /^(.*\.dat)/ =~ tmp then  
          thread_dat_url.push(base_url + 'dat/' + $1)
        end

        # 配列の要素数が取得するスレッド数に達した場合
        break if thread_dat_url.size >= thread_limit
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


end
