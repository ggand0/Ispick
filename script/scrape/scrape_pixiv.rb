# -*- coding: utf-8 -*-
# coding: utf-8
require 'securerandom'
require "#{Rails.root}/script/scrape/client"


module Scrape
  class Pixiv < Client
    ROOT_URL = 'http://www.pixiv.net/'


    # Constructor.
    # @param logger [ActiveSupport::Logger]
    # @param limi [Integer] Maximum number of images to scrape
    def initialize(logger=nil, limit=200)
      self.limit = limit
      if logger.nil?
        self.logger = Logger.new('log/scrape_pixiv_cron.log')
      else
        self.logger = logger
      end
      self.logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    end


    # Scrape images from pixiv RSS. The latter two params are used for testing.
    # @param [Integer] Given time for scraping[min]
    def scrape(interval=60)
      #@limit = 200
      @logger = Logger.new('log/scrape_pixiv_cron.log')
      @logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
      result = scrape_ranking()

      @logger.info result
      @logger.info 'DONE!'
    end

    # Scrape images using TargetWord records.
    # @param [Integer] Given time for scraping[min]
    def scrape_tag(interval=60)
      #@limit = 2000
      @logger = Logger.new('log/scrape_pixiv_cron.log')
      @logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
      result = scrape_target_words('Scrape::Pixiv2', interval)

      @logger.info result
      @logger.info 'DONE!'
    end


    def self.is_range(target)
      yesterday = Date.today - 1.day
      (target.to_date - yesterday).abs <= 1
    end

    # Scrape specify day rank in images
    # example of day expression : 2015年1月1日 = 20150101
    # @param user_id [Integer] Not in use currently.
    # @param validation [Boolean] Whether it validates values during saving
    # @param logging [Boolean] Whether it outputs logs or not
    def scrape_ranking(day='',plural=1,target_word=nil, user_id=nil, validation=true, logging=true)
      result_hash = Scrape.get_result_hash
      agent = self.get_client()
      page_num = 0
      @logger.info "Starting scraping from #{ROOT_URL}..."

      while (page_num < 10)
        @logger.debug page_num
        page_num = page_num+1
        # get ranking page URL
        ranking_url = ROOT_URL + "ranking.php?mode=daily&content=illust&date=#{day}&p=#{page_num}"
        #http://www.pixiv.net/ranking.php?mode=daily&content=illust&date=&p=1

        # get ranking page page's html
        #ranking_page = Nokogiri::HTML(open(ranking_url))
        ranking_page = agent.get(ranking_url)
        start = Time.now


        # get each images
        ranking_page.search("div[class='ranking-items adjust']").search("section").each do |image|
          #puts image.attr("id")
          # skip except new illust
          next if  image.search("p").first.text != "初登場"

          illust_id = image.attr("data-id")
          # get image's URL
          page_url = ROOT_URL + "member_illust.php?mode=medium&illust_id=#{illust_id}"
          page = agent.get(page_url)

          # get image data hash
          image_data = self.get_data(page, agent, plural, illust_id)
          # get image's tags
          tags = self.get_tags_original(page)
          options = Scrape.get_option_hash(validation, false, true, (not user_id.nil?))
          
          # if image_data havs plural images, then save all images
          if image_data[:src_url].class != Array || plural==0 then
            image_id = self.class.save_image(image_data, @logger, target_word, Scrape.get_tags(tags), options)
          else
            src_url_tmp = Marshal.load(Marshal.dump(image_data[:src_url]))
            original_url_tmp = Marshal.load(Marshal.dump(image_data[:original_url]))
            
            src_url_tmp.each_with_index do |su,i|
              image_data[:src_url] = src_url_tmp[i]
              image_data[:original_url] = original_url_tmp[i]             
              image_id = self.class.save_image(image_data, @logger, target_word, Scrape.get_tags(tags), options) 
            end
          end
            
            result_hash[:duplicates] += image_id ? 0 : 1
            result_hash[:scraped] += 1 if image_id
            elapsed_time = Time.now - start
            result_hash[:avg_time] += elapsed_time
            @logger.info "Scraped from #{image_data[:src_url]} in #{elapsed_time} sec" if logging and image_id
        end
      end

      result_hash[:avg_time] = result_hash[:avg_time] / ((result_hash[:scraped]+result_hash[:duplicates])*1.0)
      result_hash
    end



    # Login to the Pixiv with Mechanize.
    # @return [Mechanize] A Mechanize instance initialized by login data
    def get_client()
      agent = Mechanize.new
      agent.ssl_version = :TLSv1
      agent.keep_alive = false
      agent.user_agent_alias = 'Windows IE 7'
      #agent.set_proxy('ec2-23-21-139-245.compute-1.amazonaws.com', 8081)
      #agent.set_proxy('54.254.198.182', 443)
      @logger.debug agent.user_agent
      @logger.debug "#{agent.proxy_addr}, #{agent.proxy_port}"
      #@logger.debug agent.get 'http://google.com'

      login_form = agent.get('http://www.pixiv.net').forms[2]
      login_form['pixiv_id'] = CONFIG['pixiv_id']
      login_form['pass'] = CONFIG['pixiv_password']
      login_form.submit

      return agent
    end


    # Get tags from a XML object.
    # @param [Nokogiri::XML]
    # @return [Array::String]
    def get_tags_original(page)
      # Get meta tags
      #tags = page.search("meta[name='keywords']").attr("content").value.split(",")

      # Get user edited tags
      tags = []
      page.search("li[class='tag']").each do |element|
        tags.push(element.css('a')[1].content)
      end

      return tags
    end

    # Get src_url by getting a thumbnail url from iphone API
    # @param page_url [String]
    # @return [String] src_url.
    def get_src_url(page_url, illust_id=nil)
      illust_id = page_url.match(/illust_id=\d*/).to_s.gsub(/illust_id=/, '').to_i if illust_id.nil?
      detail_url = "http://spapi.pixiv.net/iphone/illust.php?illust_id=#{illust_id}&PHPSESSID=0&p=1"
      html = Nokogiri::HTML(open(detail_url))
      array = html.content.split(',')
      array[9].gsub(/\"/, '')
    end

    # 画像１枚に関する情報をHashにして返す。
    # original_favorite_countの抽出にはVotesを利用
    # @param [Nokogiri::XML]
    # @param [String]
    # @return [Hash]
    def get_data(page, agent, plural, illust_id)
      #複数枚投稿or複数枚投稿形式での1枚投稿か確認
      # 0: only 1 image,
      # 1: only 1 image but special case,
      # 2: plural images
      if page.search("ul[class='meta']").first.search("li")[1].text.split(" ")[0] == "複数枚投稿" then
        manga_flg = 2
      elsif !page.search("title").text.match(/「.*」\/「.*」の漫画 \[pixiv\]/).nil? then
        manga_flg = 1
      else
        manga_flg = 0
      end

      #page_urlの取得
      page_url = page.search("meta[property='og:url']").attr("content").value

      # titleとartistの取得
      titled = page.search("meta[property='og:title']").attr("content").value.gsub(" ","").split("|")
      title = titled[0]
      artist = titled[1].split("[")[0]

      # captionの取得
      caption = page.search("meta[property='og:description']").attr("content").text
      # if there is no caption then get page title
      if caption == "" then
        caption = page.search("title").text
      end

      # posted_atの取得(例：2015年1月1日 01:15) 日本時であることを明示するために+09:00
      # 非ログイン時
      #posted_at = page.search("span[class='date']").text + "+09:00"
      #posted_at = DateTime.strptime(posted_at,"%Y年%m月%d日 %H:%M%Z")
      # ログイン時
      posted_at = page.search("ul[class='meta']").first.search("li")[0].text + "+09:00"
      posted_at = DateTime.strptime(posted_at,"%Y年%m月%d日 %H:%M%Z")

      # src_urlの取得
      # 非ログイン時
      #src_url = page.search("div[class='img-container']").search("img").first.attr("src")
      # ログイン時
      if manga_flg != 2 || plural==0 then
        #src_url = page.search("div[class='works_display']").first.search("img").first.attr("src")
        src_url = self.get_src_url(page_url, illust_id)
      else
        src_url = []
        images_url = ROOT_URL + page.search("div[class='works_display']").first.search("a").first.attr("href")
        images_page = agent.get(images_url)
        images_page.search("img[class='image ui-scroll-view']").each_with_index do |image,c|
          if c == 0
            src_url.push(page.search("div[class='works_display']").first.search("img").first.attr("src"))
          else
            src_url.push(image.attr("data-src"))
          end
        end
      end


      # original_urlの取得(need login)
      # 非ログイン時
      #original_url = page.search("div[class='img-container']").search("img").first.attr("src")
      # ログイン時
      if plural==0 then
        if manga_flg == 0 then
          original_url = page.search("img[class='original-image']").first.attr("data-src")
        else
          original_url = src_url
        end
      elsif manga_flg == 1 then
        images_url = ROOT_URL + page.search("div[class='works_display']").first.search("a").first.attr("href")
        images_page = agent.get(images_url)
        original_url = images_page.search("body").first.search("img").first.attr("src")
      elsif manga_flg == 2 then
        original_url = []
        images_page.search("img[class='image ui-scroll-view']").each_with_index do |image,c|
          if c == 0
            original_url.push(image.attr("data-src"))
          else
            original_url.push(src_url[c])
          end
        end

      end

      author = "none"

      # Get score and view_count
      # 非ログイン時
      #view_count = page.search("section[class='score']").search("li")[1].text.gsub("総合点", "").to_i
      #score = page.search("section[class='score']").search("li")[0].text.gsub("閲覧数", "").to_i
      # ログイン時
      view_count = page.search("section[class='score']").first.search("dd[class='view-count']").first.text.to_i
      score = page.search("section[class='score']").first.search("dd[class='score-count']").first.text.to_i

      # Get size
      # 非ログイン時
    #size = []
    #size[0] = 100
    #size[1] = 100
      # ログイン時
      size = page.search("ul[class='meta']").first.search("li")[1].text.split("×")


      hash = {
        title: title,
        caption: caption,
        page_url: page_url,
        posted_at: posted_at,
        original_view_count: view_count,
        src_url: src_url,
        original_url: original_url,
        original_width: size[0],
        original_height: size[1],
        original_favorite_count: score,
        site_name: 'pixiv',
        module_name: 'Scrape::Pixiv',
        artist: author,
      }

      return hash
    end

  end
end
