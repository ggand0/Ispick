# -*- coding: utf-8 -*-
# coding: utf-8
require 'securerandom'
require "#{Rails.root}/script/scrape/client"


module Scrape
  class Zerochan < Client
    ROOT_URL = 'http://www.zerochan.net/'

    def initialize(logger=nil, limit=20)
      self.limit = limit
      if logger.nil?
        self.logger = Logger.new('log/scrape_zerochan_cron.log')
      else
        self.logger = logger
      end
      self.logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    end

    # 取得するPostの上限数。APIの仕様で20postsが限度
    # Scrape images from zerochan. The latter two params are used for testing.
    # @param [Integer] min
    # @param [Boolean] whether it's called for debug or not
    # @param [Boolean] whether it's called for debug or not
    def scrape(interval=60)
      @limit = 100
      @logger = Logger.new('log/scrape_zerochan_cron.log')
      @logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
      #scrape_target_words('Scrape::Zerochan', interval)
      scrape_RSS()
    end

    def self.get_agent
      agent = Mechanize.new
      agent.ssl_version = 'SSLv3'
      agent.keep_alive = false
      agent
    end

    def scrape_RSS(target_word=nil, user_id=nil, validation=true, logging=true, english=false)
      result_hash = Scrape.get_result_hash
      agent = self.class.get_agent
      start = Time.now

      # ページ数
      page_count = 0
      count = 0
      # 抽出したイラスト数
      image_data = {}
      image_data[:posted_at] = DateTime.now.to_date
      yesterday = Date.today - 1.day

      # 当日中のイラスト
      #while(image_data[:posted_at].to_date == DateTime.now.to_date and count<limit)
      while(image_data[:posted_at].to_date - yesterday) <= 1 and count < @limit
        page_count = page_count+1
        rss_url = ROOT_URL + "?p=" + page_count.to_s

        begin
          page = agent.get(rss_url)#SocketError: getaddrinfo: nodename nor servname provided, or not known
        rescue => e
          @logger.error e.inspect
          @logger.error "zerochan server is down. Aborting..."
          break
        end

        page.search("div[id='content']").first.search("ul[id='thumbs2']").first.search("li").each do |item|
          count = count + 1

          id = item.search("a").first.attributes["href"].value.gsub("\/","")  # 画像のidを取得
          image_url = item.search("img").first.attribute("src").value         # 画像のURLを取得
          page_url = ROOT_URL + id.to_s                                       # 詳細ページのURLを取得
          html = agent.get(page_url)                                          # 詳細ページをパース
          tags = self.get_tags_original(html)
          image_data = self.get_data(html, id)

          options = Scrape.get_option_hash(validation, false, true, (not user_id.nil?))
          # 保存に必要なものはimage_data, tags, validetion
          image_id = self.class.save_image(image_data, @logger, target_word, Scrape.get_tags(tags), options)

          result_hash[:duplicates] += image_id ? 0 : 1
          result_hash[:scraped] += 1 if image_id
          elapsed_time = Time.now - start
          result_hash[:avg_time] += elapsed_time
          @logger.info "Scraped from #{image_data[:src_url]} in #{elapsed_time} sec" if logging

          # Resqueで非同期的に画像解析を行う
          # 始めに画像をダウンロードし、終わり次第ユーザに配信
          if image_id and (not user_id.nil?)
            self.class.generate_jobs(image_id, 'Image', image_data[:src_url], false, target_word.class.name, target_word.id)
          end

          # limitを越えるか、その日に投稿された画像でなくなるまで
          #break if count >= limit || image_data[:posted_at].to_date != DateTime.now.to_date
          @logger.debug image_data[:posted_at].to_date
          @logger.debug count >= @limit or (image_data[:posted_at].to_date - yesterday) <= 0
          break if count >= @limit or (image_data[:posted_at].to_date - yesterday) <= 0
        end

      end

      result_hash[:avg_time] = result_hash[:avg_time] / ((result_hash[:scraped]+result_hash[:duplicates])*1.0)
      result_hash
    end


    # htmlからタグを取得
    # @param [Nokogiri::HTML]
    # @return [Array::String]
    def get_tags_original(html)
      result = []

      html.search("ul[id='tags']").first.search("a").each do |a|
        result << a.content
      end

      return result
    end

    # 画像１枚に関する情報をHashにして返す。
    # original_favorite_countの抽出にはVotesを利用
    # @param [Nokogiri::HTML]
    # @param [String]
    # @return [Hash]
    def get_data(page, id)
      # titleの取得
      title = page.search("title").first.content
      caption = page.search("div[id='content']").first.search("h1").first.content
      time = Time.parse( page.search("div[id='content']").first.search("span")[0].attr('title') )
      src_url = page.search("div[id='large']").first.search("img").first.attr('src')
      original_url = page.search("div[id='large']").first.css("img").first.attr('src')

      favorite_count = nil
      resolution =  page.search("div[id='large']").first.css('p')[1].children[0].content
      size = resolution.split('x')

      hash = {
        title: title,
        caption: caption,
        page_url: ROOT_URL + "#{id}",
        posted_at: time,
        original_view_count: nil,
        src_url: src_url,
        original_url: original_url,
        original_favorite_count: favorite_count,             # Image Rating
        site_name: 'zerochan',
        module_name: 'Scrape::Zerochan',
        artist: nil,
        original_height: size[1],
        original_width: size[0],
      }

      return hash
    end

    # Mechanizeにより検索結果を取得
    # @param [String]
    # @return [Mechanize] Mechanizeのインスタンスを初期化して返す
    def get_search_result(query)
      agent = Mechanize.new
      agent.ssl_version = 'SSLv3'
      page = agent.get(ROOT_URL+'login')

      # login作業
      page.forms[1]['name'] = CONFIG['zerochan_username']
      page.forms[1]['password'] = CONFIG['zerochan_password']
      result = page.forms[1].click_button()

      return result
    end

  end
end
