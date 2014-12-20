# -*- coding: utf-8 -*-
# coding: utf-8
require 'securerandom'
require "#{Rails.root}/script/scrape/client"


module Scrape
  class Anipic < Client
    ROOT_URL = 'http://anime-pictures.net'

    def initialize(logger=nil, limit=20)
      self.limit = limit
      if logger.nil?
        self.logger = Logger.new('log/scrape_anipic_cron.log')
      else
        self.logger = logger
      end
      self.logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    end

    # 取得するPostの上限数。APIの仕様で20postsが限度
    # Scrape images from anipic. The latter two params are used for testing.
    # @param [Integer] min
    def scrape(interval=60)
      @limit = 20
      @logger = Logger.new('log/scrape_anipic_cron.log')
      @logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
      #scrape_target_words('Scrape::Anipic', interval)
      result = scrape_RSS()

      @logger.info result
      @logger.info 'DONE!'
    end

    def scrape_tag(interval=60)
      @limit = 20
      @logger = Logger.new('log/scrape_anipic_cron.log')
      @logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
      result = scrape_target_words('Scrape::Anipic', interval)

      @logger.info result
      @logger.info 'DONE!'
    end

    # キーワードによる抽出処理を行う
    # @param [TargetWord]
    def scrape_target_word(user_id, target_word, english=false)
      @limit = 10
      @logger.info "Extracting #{@limit} images from: #{ROOT_URL}"

      result = scrape_using_api(target_word, user_id, true, false, english)
      @logger.info "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, skipped: #{result[:skipped]}, avg_time: #{result[:avg_time]}"
    end

    # 対象のタグを持つPostの画像を抽出する
    # @param [String]
    # @param [Integer]
    # @param [Boolean]
    # @return [Hash] Scraping result
    def scrape_using_api(target_word, user_id=nil, validation=true, logging=false, english=false)
      @limit = 200
      @logger.debug "#{target_word.inspect}"
      result_hash = Scrape.get_result_hash

      if english
        query = Scrape.get_query_en(target_word, 'roman')
      else
        query = Scrape.get_query_en(target_word, '')
      end
      if query.nil? or query.empty?
        result_hash[:info] = 'query was nil or empty'
        return result_hash
      end
      @logger.info "query=#{query}"

      # Mecanizeによりクエリ検索結果のページを取得
      page = self.get_search_result(query)
      # タグ検索：@limitで指定された数だけ画像を取得(最高80枚=1ページの最大表示数)　→ src_urlを投げる for anipic
      return if page.search("span[class='img_block_big']").count == 0

      page.search("span[class='img_block_big']").each_with_index do |image, count|
        # 広告又はR18画像はスキップ
        if image.children.search('img').first.nil?
          result_hash[:skipped] += 1
          next
        else
          # サーチ結果ページから、ソースページのURLを取得
          page_url = ROOT_URL + image.children.search('a').first.attributes['href'].value
        end

        # ソースページのパース
        xml = Nokogiri::XML(open(page_url))

        # ソースページから画像情報を取得してDBへ保存する
        start = Time.now

        begin
          image_data = self.get_data(xml, page_url)
          #@logger.debug "src_url: #{image_data.src_url}"
        rescue => e
          @logger.error "An error has occurred inside the get_data method. count: #{count}"
          send_error_mail(e, 'Scrape::Anipic', target_word, "count=#{count}") if Rails.env.production?
          next
        end
        options = Scrape.get_option_hash(validation, false, false, (not user_id.nil?))
        tags = self.get_tags_original(xml)

        # 保存に必要なものはimage_data, tags, validetion
        image_id = self.class.save_image(image_data, @logger, target_word, Scrape.get_tags(tags), options)

        result_hash[:duplicates] += image_id ? 0 : 1
        result_hash[:scraped] += 1 if image_id
        elapsed_time = Time.now - start
        result_hash[:avg_time] += elapsed_time
        @logger.info "Scraped from #{image_data[:src_url]} in #{elapsed_time} sec" if logging and res

        # Resqueで非同期的に画像解析を行う
        # 始めに画像をダウンロードし、終わり次第ユーザに配信
        if image_id and (not user_id.nil?)
          self.class.generate_jobs(image_id, image_data[:src_url], false,
            target_word.class.name, target_word.id)
        end

        # @limit枚抽出したら終了
        break if (count+1 - result_hash[:skipped]) >= @limit
      end

      result_hash[:avg_time] = result_hash[:avg_time] / ((result_hash[:scraped]+result_hash[:duplicates])*1.0)
      result_hash
    end

    def self.is_range(target)
      yesterday = Date.today - 1.day
      #puts (target.to_date - yesterday).abs
      #puts (target.to_date - yesterday).to_i.abs
      (target.to_date - yesterday).abs <= 1
    end

    # Get RSS
    def scrape_RSS(target_word=nil, user_id=nil, validation=true, logging=true)
      result_hash = Scrape.get_result_hash

      page_num = -1
      image_data = {}
      image_data[:posted_at] = Date.today
      yesterday = Date.today - 1.day

      # When you need to scrape images that are posted at that day:
      # 当日分だけ抽出する場合
      @logger.debug self.class.is_range(image_data[:posted_at]).inspect
      while self.class.is_range(image_data[:posted_at])# and result_hash[:duplicates] < 5
        @logger.debug "#{image_data[:posted_at]}, #{Date.yesterday} | page_num=#{page_num}"
        page_num = page_num+1

        # E.g. http://anime-pictures.net/pictures/view_posts/0
        rss_url = ROOT_URL + "/pictures/view_posts/" + page_num.to_s
        page = Nokogiri::HTML(open(rss_url))

        page.search("span[class='img_block_big']").each_with_index do |image, count|

          # 広告又はR18画像はスキップ
          if image.children.search('img').first.nil?
            result_hash[:skipped] += 1
            @logger.debug "skipped, #{count}"
            next
          # サーチ結果ページから、ソースページのURLを取得
          else
            page_url = ROOT_URL + image.children.search('a').first.attributes['href'].value
            @logger.debug "page_url: #{page_url}"
          end

          # ソースページのパース
          xml = Nokogiri::XML(open(page_url))

          # ソースページから画像情報を取得してDBへ保存する
          start = Time.now

          begin
            image_data = self.get_data(xml, page_url)
            @logger.debug "src_url: #{image_data[:src_url]}"
          rescue => e
            @logger.error "An error has occurred inside get_data method. count: #{count}"
            send_error_mail(e, 'Scrape::Anipic', target_word, "count=#{count}") if Rails.env.production?
            next
          end

          options = Scrape.get_option_hash(validation, false, true, (not user_id.nil?))
          tags = self.get_tags_original(xml)

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
            self.class.generate_jobs(image_id, image_data[:src_url], false,
              target_word.class.name, target_word.id)
          end

          # 80枚（1pageの最大数）抽出するまで
          #break if count+1 >= 80 || image_data[:posted_at].to_date != DateTime.now.to_date
          @logger.debug image_data[:posted_at].to_date
          break if count+1 >= 80 or (image_data[:posted_at].to_date - Date.yesterday) <= 0

          # Finish scraping if it's detected
          #break if result_hash[:duplicates] >= 5
        end
      end

      result_hash[:avg_time] = result_hash[:avg_time] / ((result_hash[:scraped]+result_hash[:duplicates])*1.0)
      result_hash
    end

    # Get the result of search, using Mechanize.
    # Mechanizeにより検索結果を取得
    # @param [String]
    # @return [Mechanize] Mechanizeのインスタンスを初期化して返す
    def get_search_result(query)
      agent = Mechanize.new
      agent.ssl_version = 'SSLv3'
      agent.keep_alive = false
      page = agent.get(ROOT_URL)

      # login作業
      #page.forms[1]['login'] = 'xxx'
      #page.forms[1]['password'] = 'xxx'
      #page.forms[1].submit

      page.forms[2]['search_tag'] = query

      result = page.forms[2].submit
      #puts(page.forms[2]['search_tags'])
      return result
    end

    # Get tags from a XML object.
    # xmlからタグを取得
    # @param [Nokogiri::XML]
    # @return [Array::String]
    def get_tags_original(xml)
      result = []
      index = 0
      xml.css("ul[class='tags']").first.css('a').each do |a|
        result[index] = a.content
        index = index + 1
      end

      return result
    end

    # TODO: Refactoring
    def self.get_time(time_string)
      # 整形
      time = time_string
      time.gsub!(/\n|\t| /,'')
      time_t = time.split(/\/|,| /)
      time_t[2] = "20" + time_t[2]

      if (time_t[3] =~ /PM/)
        time_t[3].gsub!(/PM/,'')
        h = time_t[3].split(':')[0]
        m = time_t[3].split(':')[1]

        hi = h.to_i + 12
        hi = 0 if hi==24
        time_t[3] = "#{hi}:#{m}"
      else
        time_t[3].gsub!(/AM/,'')
      end

      # UTCに変換
      time_t[2] + "/" + time_t[0] + "/" + time_t[1] + "/" + time_t[3]
    end

    # 画像１枚に関する情報をHashにして返す。
    # original_favorite_countの抽出にはVotesを利用
    # @param [Nokogiri::XML]
    # @param [String]
    # @return [Hash]
    def get_data(xml, page_url)
      # titleの取得
      # 改行の除去
      title = xml.css("div[class='post_content']").css("h1").first.content.gsub!(/\n/,'')
      # タブのスペースへの変換
      title.gsub!(/\t/,' ')
      # captionの取得
      # 改行の除去
      caption = xml.css('title').first.content.gsub!(/\n/,'')
      # タブのスペースへの変換
      caption.gsub!(/\t/,' ')

      # posted_atの取得( 8/13/14, 7:26 PM\n\t\t)
      time = xml.css("div[class='post_content']").css("b")[2].next.content
      time = self.class.get_time(time)
      time = Time.parse(time)

      # src_urlの取得
      #src_url = image_url_div.css("img").first.attributes['src'].value.gsub!(/ /,'')
      image_url_div = xml.css("div[id='big_preview_cont']")
      src_url = image_url_div.css("img").first.attributes['src'].value

      # original_urlの取得
      # aタグが上手くパース出来なかったときの例外処理
      if image_url_div.children.css("a").first.nil?
        original_url = ROOT_URL + xml.css("div[class='post_vote_block']").css("a[rel='nofollow']").first.attributes['href'].value.gsub!(/download_image/,"get_image")
      else
        original_url = ROOT_URL + image_url_div.children.search("a").first.attributes['href'].value
      end

      author = "none"
      # artistの取得
      xml.css("ul[class='tags']").first.css('span').each do |span|
        if span.content == "author"
          author = span.next_element.css('a').first.content.gsub(/\t|\n/,'')
          break
        end
      end

      # Get 'votes' count
      # 14/11/25 Fixed according to the update of html structure
      votes = xml.css("div[class='post_vote_block']").first.css("span[id='score_n']").first.content

      # Get resolution
      resolution = xml.css("div[class='post_content']").first.css('b')[4].next_element.content
      size = resolution.split('x')

      hash = {
        title: title,
        caption: caption,
        page_url: page_url,
        posted_at: time,
        original_view_count: nil,
        src_url: src_url,
        original_url: original_url,
        original_width: size[0],
        original_height: size[1],
        original_favorite_count: votes,
        site_name: 'anipic',
        module_name: 'Scrape::Anipic',
        artist: author,
      }

      return hash
    end

  end
end
