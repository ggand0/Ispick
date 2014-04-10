#-*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'kconv'
require 'x2ch'
include X2CH

# 2ちゃんねるから2次画像を抽出する
module Scrape::Nichan

  # 2ちゃんねるURL
  ROOT_URL = 'http://2ch.net/'

  # 関数定義
  def self.scrape()
    puts 'Extracting : ' + ROOT_URL

    # 2ちゃんねるのベースURL


    # 2ちゃんねるのスレッドのdatファイルURLを取得する
    bbs = Bbs.load
    boards = [
      #'http://toro.2ch.net/illustrator/',    # イラストレータ板
      #'http://toro.2ch.net/anime/'            # アニメ板
      bbs['漫画・小説等']['イラストレーター'],
      bbs['漫画・小説等']['アニメ２']
    ]
    limit = 5
    image_data = []
    count = 0
    boards.each do |board|
      count = 0
      board.threads.each do |thread|
        #puts thread.url   # http://ikura.2ch.net/anime2/
        #puts thread.dat   # 9246366142.dat
        #puts thread.name  # 各関係者様
        #puts thread.num   # 1

        thread.each do |post|
          #puts "#{post.name} <> #{post.mail} <> #{post.metadata} <> #{post.body}"
          metadata = post.metadata
          metadata.gsub!(/ ID:.*|¥..*|¥(.*¥)/, '') # => 2014/03/31 03:02:12
          posted_at = DateTime.parse(metadata).change(offset: '+0900').utc

          extensions = ['jpg', 'png', 'gif']
          extensions.each do |ext|
            urls = post.body.to_s.scan(/http:\/\/.*?\.#{ext}/i)
            urls.each do |src_url|
              info = {
                title: self.get_image_name(src_url),
                caption: post.body.to_s,
                src_url: src_url,
                page_url: thread.url+'dat/'+thread.dat,
                site_name: '2ch',
                posted_atß: posted_at
              }
              image_data.push(info)

              printf("%s : %s\n", info[:title], info[:src_url])
              Scrape::save_image(info)
            end
          end
        end
        break if count >= limit
        count += 1
      end
    end

    #boards.each do |board_url|
    #  self.scrape_board(board_url, limit)
    #end
  end

  def self.scrape_board(board_url, limit)
    thread_dats = self.get_dat_url(board_url, limit)    # ハッシュ

    # 画像URLを取得する
    img_url_array = []    # 空の配列
    thread_dats.each do |dat|
      # datファイルの内容を文字列として取得
      dat_text = Nokogiri::HTML(open(dat[:url])).to_s
      str = "㎡"
      dat_text.delete!(str)   # 環境依存文字を除外
      img_url_array.push({ url: self.get_img_url(dat_text), title: dat[:title] })
    end

    # URLの重複をなくす
    img_url_array.uniq!

    # URLの配列について処理
    # zipで2配列をiterateする：http://goo.gl/6ikMRg
    img_url_array.each do |img|
      img[:url].each do |url|
        img_title = self.get_image_name(url)      # 画像のタイトルを決定
        printf("%s : %s\n", img[:title], url)           # 出力テスト

        #Scrape::save_image(img_title, url)        # Imageモデル生成＆DB保存
        Scrape::save_image(img[:title], url)            # Imageモデル生成＆DB保存
      end
    end
  end

  # スレッドのdatファイルへのURLを新着順に取得し、配列で返す関数
  def self.get_dat_url(base_url, limit)
    # subject.txtのURL
    subject_url = base_url + 'subject.txt'

    # スレッドのURLを取得
    thread_dats = []    # 空の配列
    open(subject_url) do |con|
      con.each do |line|
        # datファイルのURLを配列に追加
        if /^(.*\.dat)/ =~ line then        # 正規表現にその行がマッチすれば
          dat_url = base_url + 'dat/' + $1  # マッチした文字列をurlに使用

          # "xxx.dat<>"後の文字列がタイトルであると見越して取得
          thread_title = line.match(/.*dat<>/).post_match

          # HashのArrayとする
          thread_dats.push({ url: dat_url, title: thread_title.toutf8 })
        end

        return thread_dats if thread_dats.size >= limit
      end
    end

    thread_dats
  end

  # datファイルのテキストから画像のURLを取得し、配列で返す関数
  def self.get_img_url(text)
    #puts text
    #puts text.split('<>').count
    posts = []
    puts text.toutf8
    dsf
    text.toutf8.each_line do |l|
      puts l
      m = l.match(/^(\d+)<>(.+?)<>(.*?)<>(.*?)<>(.+)<>.*$/).to_a
      if m[0]
        posts << Post.new(m[2], m[3], m[4], m[5])
      else
        m = l.match(/^(.+?)<>(.*?)<>(.*?)<>(.+)<>.*$/).to_a
        if m[0]
          posts << Post.new(m[1], m[2], m[3], m[4])
        end
      end
    end
    puts posts
    fds

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
