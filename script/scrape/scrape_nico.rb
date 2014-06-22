# coding: utf-8
require 'open-uri'

module Scrape::Nico
  RSS_URL = 'http://seiga.nicovideo.jp/rss/illust/new'
  TAG_SEARCH_URL = 'http://seiga.nicovideo.jp/api/tagslide/data'
  ROOT_URL = 'http://seiga.nicovideo.jp'

  def self.scrape
    agent = self.get_client
    limit = 50
    puts "Start extracting from #{ROOT_URL}: time=#{DateTime.now}"

    TargetWord.all.each do |target_word|
      if target_word.enabled
        begin
          query = target_word.person ? target_word.person.name : target_word.word
          puts "query = #{query}"
          self.scrape_with_keyword(agent, query, limit, true)
        rescue => e
          puts e
          Rails.logger.info("Scraping from #{ROOT_URL} has failed!")
        end
      end
    end

  end

  # キーワードによる検索
  def self.scrape_keyword(keyword)
    agent = self.get_client
    limit = 10
    self.scrape_with_keyword(agent, keyword, limit, true)
  end

  # キーワードからタグ検索してlimit分の画像を保存する
  def self.scrape_with_keyword(agent, keyword, limit, validation)
    # nilのクエリを送らないようにする
    return if keyword.nil? or keyword.empty?

    url = "#{TAG_SEARCH_URL}?page=1&query=#{keyword}"
    escaped = URI.escape(url)
    xml = agent.get(escaped)
    duplicates = 0
    id_array = []

    # 画像情報を取得してlimit枚DBヘ保存する
    puts "Extracting #{limit.to_s} images from: #{url}"
    puts xml.search('image').count
    xml.search('image').take(limit).each_with_index do |item, count|
      begin
        start = Time.now
        next if item.css('adult_level').first.content.to_i > 0  # 春画画像はskip
        image_data = self.get_data(item)                        # APIの結果から画像情報取得
        #self.get_contents(page_url, agent, image_data, validation)# hashを渡して残りを抽出
        # 抽出した画像を保存
        #res = Scrape::save_image(image_data, [], validation)
        res = Scrape::save_image(image_data, [self.get_tag(keyword)] , validation)
        duplicates += res ? 0 : 1
        id_array.push(res)
        puts "Scraped from #{image_data[:src_url]} in #{(Time.now - start).to_s} sec" if res

        break if duplicates >= 3
      rescue
        next  # 検索結果が0の場合など
      end
      break if count+1 >= limit
    end
    id_array
  end

  def self.get_data(item)
    {
      title: item.css('title').first.content,
      caption: item.css('description').first.content,
      src_url: "http://lohas.nicoseiga.jp/thumb/#{item.css('id').first.content}i",
      page_url: "http://seiga.nicovideo.jp/seiga/im#{item.css('id').first.content}",
      views: item.css('view_count').first.content,
      favorites: item.css('clip_count').first.content,
      posted_at: DateTime.parse(item.css('created').first.content),
      site_name: 'nicoseiga',
      module_name: 'Scrape::Nico',
    }
  end

  # page_urlから情報・画像抽出
  def self.get_contents(page_url, agent, image_data, validation=true)
    start = Time.now
    begin
      page = agent.get(page_url)  # 元ページを開く
    rescue Exception => e         # ログイン求められて失敗した場合など
      puts "Failed to open page_url: #{page_url}"
      puts e
      Rails.logger.info('Could not open a page.')
      return
    end

    # タグ情報を取得
    tag_string = page.at("meta[@name='keywords']").attr('content')
    tags = self.get_tags(tag_string.split(','))

    # Imageレコードをupdate
    #Scrape::save_image(hash.merge(image_data), tags, validation)

    puts "Updated in #{(Time.now - start).to_s} sec"
  end

  # Mechanizeによるログイン
  def self.get_client
    agent = Mechanize.new
    agent.ssl_version = 'SSLv3'
    agent.post('https://secure.nicovideo.jp/secure/login?site=seiga',
      'mail' => CONFIG['nico_email'],'password' => CONFIG['nico_password'])
    agent
  end

  def self.get_tag(tag)
    t = Tag.where(name: tag)
    t.empty? ? Tag.new(name: tag) : t.first
  end
  # タグを取得する。DBに既にある場合はそのレコードを返す
  def self.get_tags(tags)
    tags.map do |tag|
      t = Tag.where(name: tag)
      t.empty? ? Tag.new(name: tag) : t.first
    end
  end

  # delivered_images update用に、
  # ログインしてstats情報だけ返す関数
  def self.get_stats(agent, page_url)
    begin
      page = agent.get(page_url)
      info_elements = page.at("ul[@class='illust_count']")
      views = info_elements.css("li[class='view']").css("span[class='count_value']").first.content
      comments = info_elements.css("li[class='comment']").css("span[class='count_value']").first.content
      clips = info_elements.css("li[class='clip']").css("span[class='count_value']").first.content
    rescue => e
      return false
    end

    { views: views, favorites: clips}
  end
end