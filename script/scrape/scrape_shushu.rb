# -*- coding: utf-8 -*-
# coding: utf-8
require 'securerandom'
require "#{Rails.root}/script/scrape/client"


module Scrape
  class Shushu < Client
    ROOT_URL = 'http://e-shuushuu.net/'

    def initialize(logger=nil, limit=20)
      self.limit = limit
      if logger.nil?
        self.logger = Logger.new('log/scrape_shushu_cron.log')
      else
        self.logger = logger
      end
      self.logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    end

    # 取得するPostの上限数。APIの仕様で20postsが限度
    # Scrape images from shushu. The latter two params are used for testing.
    # @param [Integer] min
    # @param [Boolean] whether it's called for debug or not
    # @param [Boolean] whether it's called for debug or not
    def scrape(interval=60)
      @limit = 100
      @logger = Logger.new('log/scrape_shushu_cron.log')
      @logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
      #scrape_target_words('Scrape::Shushu', interval)
      scrape_RSS()
    end

    def scrape_RSS(target_word=nil, user_id=nil, validation=true, logging=true)
      result_hash = Scrape.get_result_hash
      start = Time.now

      rss_url = ROOT_URL + "index.rss"
      xml = Nokogiri::XML(open(rss_url))

      xml.search("item").each_with_index do |item, count|
        id = item.search("link").first.content.split("/")[4].split("-")[3].split(".")[0]  # 画像のidを取得
        image_url = item.search("link").first.content                                     # 画像のURLを取得
        page_url = ROOT_URL + "image/#{id}/"                                              # 詳細ページのURLを取得
        html = Nokogiri::HTML(open(page_url))

        tags = self.get_tags_original(html)
        image_data = self.get_data(html, id)
        options = Scrape.get_option_hash(validation, false, true, (not user_id.nil?))

        # 保存に必要なものはimage_data, tags, validetion
        image_id = self.class.save_image(image_data, @logger, target_word, Scrape.get_tags(tags), options)

        result_hash[:duplicates] += image_id ? 0 : 1
        result_hash[:scraped] += 1 if image_id
        elapsed_time = Time.now - start
        result_hash[:avg_time] += elapsed_time
        @logger.info "Scraped from #{image_data[:src_url]} in #{elapsed_time} sec" if logging and image_id


        # Resqueで非同期的に画像解析を行う
        # 始めに画像をダウンロードし、終わり次第ユーザに配信
        if image_id and (not user_id.nil?)
          self.class.generate_jobs(image_id, 'Image', image_data[:src_url], false, target_word.class.name, target_word.id)
        end

        # limitを越えるか、その日に投稿された画像でなくなるまで
        #break if count >= limit || image_data[:posted_at].to_date != DateTime.now.to_date
        #@logger.debug (count+1 >= @limit or (image_data[:posted_at].to_date - Date.yesterday) <= 0).inspect
        @logger.debug image_data[:posted_at].to_date
        break if count+1 >= @limit or image_data[:posted_at].to_date - (Date.today - 1.day) <= 0
      end

      result_hash[:avg_time] = result_hash[:avg_time] / ((result_hash[:scraped]+result_hash[:duplicates])*1.0)
      result_hash
    end


    # htmlからタグを取得
    # @param [Nokogiri::HTML]
    # @return [Array::String]
    def get_tags_original(html)
      result = []
      labels = ['Tags:', 'Source:', 'Character:']

       # その他の取得
      html.css("div[id='content']").first.css("dt").each do |dt|
        #if dt.content.gsub!(/\t|\n/,"") == "Tags:" or dt.content.gsub!(/\t|\n/,"") == "Source:" || dt.content.gsub!(/\t|\n/,"") == "Character:" then
        if labels.include?(dt.content.gsub!(/\t|\n/,""))
          tags = dt.next.next.content.gsub!(/\t|\n/,"").split("\"")
          tags.reject! { |t| t.empty? or t==" "}
          tags.each do |tag|
            if tag != ""
              result << tag
            end
          end
        end

      end

      return result
    end

    # 画像１枚に関する情報をHashにして返す。
    # original_favorite_countの抽出にはVotesを利用
    # @param [Nokogiri::HTML]
    # @param [String]
    # @return [Hash]
    def get_data(html, id)
      # titleの取得
      title = "shushu:Image #" + id
      caption = title
      time = nil
      src_url = nil
      original_url = nil
      author = nil
      favorite_count = nil
      height = nil
      width = nil
      # その他の取得
      html.css("div[id='content']").first.css("dt").each do |dt|
        #puts dt.content.gsub(/\t|\n/,"")
        case dt.content.gsub(/\t|\n/,"")
        when "Submitted On:" then
          # posted_atの取得
          time = DateTime.parse(dt.next.next.content)

        when "Filename:" then
          # src_urlの取得
          src_url = ROOT_URL + "images/thumbs/#{dt.next.next.content.split(".").first}.jpeg"
          # original_urlの取得
          original_url = ROOT_URL + "images/#{dt.next.next.content}"
        when "Artist:" then
          # authorの取得
          author = dt.next.next.content.gsub!(/\t|\n|\/|\"/,"")

        when "Image Rating:" then
          # favorite_countの取得
          favorite_count = dt.next.next.content.gsub!(/\t|\n"/,"")
          if favorite_count == "N/A"
            favorite_count = 0
          else
            favorite_count = favorite_count.to_i
          end
        when "Dimensions:" then
          height = dt.next.next.content.split(" ").first.split("x").second.to_i
          width = dt.next.next.content.split(" ").first.split("x").first.to_i
        else
        end
      end

      hash = {
        title: title,
        caption: caption,
        page_url: ROOT_URL + "image/#{id}/",
        posted_at: time,
        original_view_count: nil,
        src_url: original_url,#src_url,
        original_url: original_url,
        original_favorite_count: favorite_count,             # Image Rating
        site_name: 'shushu',
        module_name: 'Scrape::Shushu',
        artist: author,
        height: height,
        width: width,
        original_height: height,
        original_width: width,
      }

      return hash
    end

  end
end
