#-*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'json'
require 'securerandom'


# 4chanから2次画像を抽出する
module Scrape::Fourchan
  ROOT_URL = 'http://www.4chan.org/'

  def self.scrape
    board = 'c'       # 板の名称(タイトルではない)
    limit = 15        # thread数のlimit。1page 15threads

    # スレッドの内容を取得する
    puts 'Extracting : ' + ROOT_URL
    thread_id = self.get_thread_id_list(board, limit)
    thread_post = self.get_thread_post_list(board, thread_id)
    image_url = self.get_image_url_list(board, thread_post)
    puts "count: #{image_url.length.to_s}" if image_url

    # Imageレコード作成＆DB保存
    image_url.each do |value|
      value[:title] = self.get_image_name(value[:src_url])
      is_large = value[:is_large]
      value.delete(:is_large)
      puts "#{value[:title]} : #{value[:src_url]}"

      success = Scrape::save_image(value, [], true, is_large)
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
  # @param [Integer] 取得するboard数
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
      thread_post_list.push({ posts: data['posts'], id: id, tag: self.get_tag_from_comment(data['posts']) })
    end
    thread_post_list
  end

  # 1レス目のtitle/captionからタグ付けする、
  # 出来た場合は全てのレスに対して同じタグを付ける
  # @param [Hash] １つのスレッド内の全てのpost
  def self.get_tag_from_comment(posts_hash)
    title = posts_hash.first['com']
    caption = posts_hash.first['com']

    # TODO: text analyser で英名を抜き出す
    []
  end

  # スレッドの内容の配列から画像URLを取得する関数
  # @param [String] boardを表すcharacter('c'など)
  # @param [Array] postsとthread_id属性を持ったHashのArray
  # @return [Array] image_dataの配列
  def self.get_image_url_list(board, thread_post)
    image_url = []
    thread_post.each do |post|
      post[:posts].each do |value|
        if value.has_key?('tim') and value.has_key?('ext')# then
          url = "http://i.4cdn.org/%s/src/%s%s" % [board, value['tim'], value['ext']]
          caption = value['com'] if value.has_key?('com')
          posted_at = self.get_posted_at(value['now'])
          #is_large = true if (value['fsize'] / (1024.0*1024.0)) > 2　 # 2MB以上ならlarge用のqueueへ
          is_large = false

          image_data = {
            src_url: url,
            page_url: "http://boards.4chan.org/%s/res/%d" % [board, post[:id]],
            caption: caption,
            posted_at: posted_at,
            is_large: is_large
          }

          image_url.push(image_data)
        end
      end
    end
    image_url
  end

  # 投稿日時を取得する
  # @param [String] '03\/24\/14(Mon)16:09'など
  # @return [Time] UTC時
  def self.get_posted_at(time_string)
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
      return image_name.to_s
    end
  end

end
