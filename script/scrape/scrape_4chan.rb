#-*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'json'
require 'securerandom'


# 4chanから2次画像を抽出する
module Scrape::Fourchan

  # 4chanURL
  ROOT_URL = 'http://www.4chan.org/'

  # 関数定義
  def self.scrape()
    puts 'Extracting : ' + ROOT_URL

    # 変数
    board = 'c'   # 板の名称(タイトルではない)
    limit = 5     # サイズが大きい画像が多くうpされている事に注意
    image_limit = 50

    # スレッドの内容を取得する
    thread_id = self.get_thread_id_list(board, limit)
    puts thread_id.length.to_s
    thread_post = self.get_thread_post_list(board, thread_id)
    image_url = self.get_image_url_list(board, thread_post)
    puts 'count:'+image_url.length.to_s

    # Imageモデル生成＆DB保存
    count = 0
    image_url.each do |value|
      img_name = self.get_image_name(value[:src_url])
      value[:title] = img_name
      printf("%s : %s\n", img_name, value[:src_url])

      # image_limitの枚数分抽出する
      success = Scrape::save_image(value)
      count += success ? 1 : 0
      break if count >= image_limit
    end
  end

  # 4chan内の板の一覧(ハッシュ)を取得する関数
  def self.get_board_list()
    url = 'http://a.4cdn.org/boards.json'
    json = open(url).read
    data = JSON.parse(json)
    board_list = {}
    data['boards'].each do |value|
      board_list[value['title']] = value['board']
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
      page['threads'].each do |thread|
        thread_id_list.push(thread['no'])
        if thread_id_list.size >= limit then
          thread_is_list = thread_id_list[0, limit]
          return thread_id_list   # Array
        end
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
      thread_post_list.push({ posts: data['posts'], id: id })
    end
    thread_post_list    # Array
  end

  # スレッドの内容の配列から画像URLを取得する関数
  # @thread_post : postsとthread_id属性を持ったHash
  def self.get_image_url_list(board, thread_post)
    image_url = []
    thread_post.each do |post|
      post[:posts].each do |value|
        if value.has_key?('tim') and value.has_key?('ext') then
          url = "http://i.4cdn.org/%s/src/%s%s" % [board, value['tim'], value['ext']]
          com = value['com'] if value.has_key?('com')

          # 投稿日時を取得する
          time_string = value['now']                   # 03\/24\/14(Mon)16:09
          date = time_string.match(/.*\(/).to_s.delete!('(').split('/')  # 03, 24, 14
          month = date[0].to_i
          day = date[1].to_i
          year = ('20'+date[2]).to_i
          hour = time_string.match(/\d\d:/).to_s.delete!(':').to_i
          min = time_string.match(/:\d\d/).to_s.delete!(':').to_i
          posted_at = Time.mktime(year, month, day, hour, min).in_time_zone('Asia/Tokyo').utc

          image_data = {
            src_url: url,
            # e.g. 'http://boards.4chan.org/c/res/2166071'
            page_url: "http://boards.4chan.org/%s/res/%d" % [board, post[:id]],
            caption: com,
            posted_time: posted_at
          }

          #image_url.push({ url: url, com: com })
          image_url.push(image_data)
        end
      end
    end
    image_url   # Array
  end

  # 画像の名称を決定する
  def self.get_image_name(url)
    if /.+\/(.*)?\..*/ =~ url then
      image_name = '4chan_' + $1
      return image_name
    else
      image_name = SecureRandom.random_number(10**14)  # ランダムな14桁の数値
      return image_name
    end
  end

end
