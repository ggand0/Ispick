#-*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'json'
require 'securerandom'


# 4chanから2次画像を抽出する
module Scrap::Fourchan

  # 4chanURL
  ROOT_URL = 'http://www.4chan.org/'
  
  # 関数定義
  def self.scrap()
    puts 'Extracting : ' + ROOT_URL

    # 変数
    board = "c"   # 板の名称(タイトルではない)
    limit = 5

    # スレッドの内容を取得する
    thread_id = self.get_thread_id_list(board, limit)
    thread_post = self.get_thread_post_list(board, thread_id)
    image_url = self.get_image_url_list(board, thread_post)

    # Imageモデル生成＆DB保存
    image_url.each do |value|
      img_name = self.get_image_name(value)
      printf("%s : %s\n", img_name, value)
      Scrap::save_image(img_name, value)
    end

  end
  
  # 4chan内の板の一覧(ハッシュ)を取得する関数
  def self.get_board_list()
    url = "http://a.4cdn.org/boards.json"
    json = open(url).read
    data = JSON.parse(json)
    board_list = {}
    data["boards"].each do |value|
      board_list[value["title"]] = value["board"]
    end
    board_list    # Hash
  end

  # 板のスレッドID一覧の配列を取得する関数
  def self.get_thread_id_list(board, limit)
    url = "http://a.4cdn.org/%s/threads.json" % [board]
    json = open(url).read
    data = JSON.parse(json)
    thread_id_list = []
    data.each do |page|
      thread_id_list = page["threads"].map { |value| value["no"] }
      if thread_id_list.size >= limit then
        thread_is_list = thread_id_list[0, limit]
        return thread_id_list   # Array
      end
    end
    thread_id_list    # Array
  end

  # スレッドIDを受け取ってスレッドの内容を配列で返す関数
  def self.get_thread_post_list(board, thread_id_list)
    thread_post_list = []
    thread_id_list.each do |id|
      url = "http://a.4cdn.org/%s/res/%s.json" % [board, id]
      json = open(url).read
      data = JSON.parse(json)
      thread_post_list.push(data["posts"])
    end
    thread_post_list    # Array
  end

  # スレッドの内容の配列から画像URLを取得する関数
  def self.get_image_url_list(board, thread_post)
    image_url = []
    thread_post.each do |post|
      post.each do |value|
        if value.has_key?("tim") and value.has_key?("ext") then
          url = "http://i.4cdn.org/%s/src/%s%s" % [board, value["tim"], value["ext"]]
          image_url.push(url)
        end
      end
    end
    image_url   # Array
  end

  # 画像の名称を決定する
  def self.get_image_name(url)
    if /.+\/(.*)?\..*/ =~ url then
      image_name = "4chan_" + $1
      return image_name
    else
      image_name = SecureRandom.random_number(10**14)  # ランダムな14桁の数値
      return image_name
    end
  end

end
