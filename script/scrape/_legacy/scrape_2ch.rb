#-*- coding: utf-8 -*-
require 'x2ch'
include X2CH

module Scrape::Nichan
  ROOT_URL = 'http://2ch.net/'

  # 2ちゃんねるから2次画像を抽出する
  def self.scrape
    boards = self.get_boards

    # 対象の板から画像抽出する
    puts "Extracting: #{ROOT_URL}"
    self.scrape_boards boards, 5
  end

  # 画像抽出対象のBoardsオブジェクトの配列を作成して返す
  # @return [Array] Array of X2CH::Board objects
  def self.get_boards
    bbs = Bbs.load
    boards = [
      bbs['漫画・小説等']['イラストレーター'],
      bbs['漫画・小説等']['アニメ２']
    ]
    boards
  end

  # 与えられた板の画像を抽出する
  # @param [Array] 板のURL
  # @param [Integer] １つの板当たりの抽出スレッド数
  def self.scrape_boards(boards, limit)
    boards.each do |board|
      board.threads.each_with_index do |thread, count|
        #puts thread.url   # => http://ikura.2ch.net/anime2/
        #puts thread.dat   # => 9246366142.dat
        #puts thread.name  # => 各関係者様
        #puts thread.num   # => 1
        self.scrape_posts thread

        break if count >= limit
      end
    end
  end

  # スレッド内の全てのレスをチェックして画像抽出する
  # @param [X2ch::Thread] １スレッドに相当するX2chのオブジェクト
  def self.scrape_posts(thread)
    extensions = ['jpg', 'png', 'gif']

    thread.each do |post|
      #puts "#{post.name} <> #{post.mail} <> #{post.metadata} <> #{post.body}"
      posted_at = self.get_posted_at post.metadata

      extensions.each do |ext|
        urls = post.body.to_s.scan(/http:\/\/.*?\.#{ext}/i)
        urls.each do |src_url|
          info = {
            title: self.get_image_name(src_url),
            caption: post.body.to_s,
            src_url: src_url,
            page_url: "#{thread.url}dat/#{thread.dat}",
            site_name: '2ch',
            posted_at: posted_at
          }

          success = Scrape::save_image(info)
          puts "#{info[:title]} : #{info[:src_url]}" if success
        end
      end
    end
  end

  # レスの投稿日時を取得する
  # @param [String] レスのヘッダ文字列
  # @param [DateTime] 書き込み日時
  def self.get_posted_at(metadata)
    metadata.gsub!(/ ID:.*|¥..*|¥(.*¥)/, '')              # => 2014/03/31 03:02:12
    DateTime.parse(metadata).change(offset: '+0900').utc
  end

end
