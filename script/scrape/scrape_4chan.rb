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
  def self.scrape
    puts 'Extracting : ' + ROOT_URL

    # 変数
    board = 'c'       # 板の名称(タイトルではない)
    limit = 15        # thread数のlimit。1page 15threads
    #image_limit = 50

    # スレッドの内容を取得する
    thread_id = self.get_thread_id_list(board, limit)
    thread_post = self.get_thread_post_list(board, thread_id)
    image_url = self.get_image_url_list(board, thread_post)
    puts "count: #{image_url.length.to_s}"

    # Imageモデル生成＆DB保存
    count = 0
    image_url.each do |value|
      img_name = self.get_image_name(value[:src_url])
      value[:title] = img_name
      printf("%s : %s\n", img_name, value[:src_url])

      # image_limitの枚数分抽出する
      success = Scrape::save_image(value)
      count += success ? 1 : 0
      #break if count >= image_limit
    end
  end


  # 4chan内の板の一覧(Hash)を取得する
  # @return [Hash]
  def self.get_board_list
    url = 'http://a.4cdn.org/boards.json'
    json = open(url).read
    data = JSON.parse(json)
    board_list = {}
    data['boards'].each do |value|
      board_list[value['title']] = value['board']
    end
    board_list
  end

  # 板のスレッドID一覧の配列を取得する関数
  # @param [String] boardを表すcharacter('c'など)
  # @return [Array] スレッドID一覧の配列
  def self.get_thread_id_list(board, limit)
    url = "http://a.4cdn.org/%s/threads.json" % [board]
    json = open(url).read
    data = JSON.parse(json)
    thread_id_list = []

    data.each do |page|
      page['threads'].each do |thread|
        thread_id_list.push(thread['no'])

        # 超過したら、要素数をlimit分に合わせてからreturn
        if thread_id_list.size >= limit then
          thread_is_list = thread_id_list[0, limit]
          return thread_id_list
        end
      end
    end
    thread_id_list
  end

  # スレッドIDを受け取ってスレッドの内容を配列で返す関数
  # @param [String] boardを表すcharacter('c'など)
  # @param [Array] スレッドID一覧の配列
  # @return [Array]
  def self.get_thread_post_list(board, thread_id_list)
    thread_post_list = []
    thread_id_list.each do |id|
      url = "http://a.4cdn.org/%s/res/%s.json" % [board, id]
      json = open(url).read
      data = JSON.parse(json)
      thread_post_list.push({ posts: data['posts'], id: id })
    end
    thread_post_list
  end

  # スレッドの内容の配列から画像URLを取得する関数
  # @param [String] boardを表すcharacter('c'など)
  # @param [Array] postsとthread_id属性を持ったHashのArray
  # @return [Array] image_dataの配列
  def self.get_image_url_list(board, thread_post)
    image_url = []
    thread_post.each do |post|
      post[:posts].each do |value|
        if value.has_key?('tim') and value.has_key?('ext') then
          url = "http://i.4cdn.org/%s/src/%s%s" % [board, value['tim'], value['ext']]
          com = value['com'] if value.has_key?('com')
          posted_at = self.get_posted_at(value)

          image_data = {
            src_url: url,
            page_url: "http://boards.4chan.org/%s/res/%d" % [board, post[:id]],
            caption: com,
            posted_at: posted_at
          }

          image_url.push(image_data)
        end
      end
    end
    image_url
  end

  # 投稿日時を取得する
  # @param [Hash] APIの結果
  # @return [Time] UTC時
  def self.get_posted_at(value)
    time_string = value['now']                                      # => 03\/24\/14(Mon)16:09
    date = time_string.match(/.*\(/).to_s.delete!('(').split('/')   # => 03, 24, 14
    month = date[0].to_i
    day = date[1].to_i
    year = ('20'+date[2]).to_i
    hour = time_string.match(/\d\d:/).to_s.delete!(':').to_i
    min = time_string.match(/:\d\d/).to_s.delete!(':').to_i

    Time.mktime(year, month, day, hour, min).in_time_zone('Asia/Tokyo').utc
  end

  # 画像の名称を決定する
  # @param [String] 画像のsource url
  # @return [String] ランダム数列が入ったuniqueな文字列
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
