# coding: utf-8
require 'nokogiri'
require 'open-uri'
require 'kconv'
require 'futaba'


module Scrape::Futaba
  ROOT_URL = 'http://www.2chan.net/'

  # ふたばちゃんねるから2次画像を抽出する
  def self.scrape
    puts "Extracting: #{ROOT_URL}"

    threads = self.get_threads
    self.scrape_threads threads, 5
  end

  def self.get_threads
    board = Futaba::Board.new('http://dat.2chan.net/img2/')
    board.catalog.threads
  end

  def self.scrape_threads(threads, limit)
    threads.each_with_index do |thread, count|
      thread.posts.each do |post|
        if post.image
          image_data = self.get_data thread, post

          success = Scrape::save_image(image_data)
          puts "#{image_data[:site_name]} : #{image_data[:src_url]}" if success
        end
      end

      break if count >= limit
    end
  end

  def self.get_data(thread, post)
    {
      title: post.title,
      caption: post.body,
      site_name: '2chan',
      src_url: post.image.uri,
      page_url: thread.uri,
      posted_at: post.date
    }
  end

end
