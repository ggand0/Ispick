# coding: utf-8
require 'open-uri'
require 'time'
require "#{Rails.root}/lib/keyword_analysis"

module Scrape::Matome

  # 画像を抽出して保存
  def self.get_img(img_items, title, caption, time, link, tags=[])
    image_url = img_items.attr('src')
    title2 = title + SecureRandom.random_number(10**14).to_s
    hash = {:src_url=> image_url,:page_url=>link, :caption=>caption, :title=>title2, :posted_at=>time, :site_name=>title, :module_name=>"Scrape::Matome"}

    logger = Logger.new('log/scrape_matome.log')
    logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    Scrape::save_image(hash, logger, tags)
  end

  # サイト固有値を返す
  def self.ptcl(key)
    mainlc=""
    title=""
    case key
      when :ika then
        mainlc = "div[class='article-body entry-content']"
        title = "いか速報"
      when :aja then
        mainlc = "div[class='blogbody']"
        title = "あじゃじゃしたー"
      when :ota then
        mainlc = "div[class='mainmore']"
        title = "萌えオタ速報"
      when :nizi then
        mainlc = "div[class='article-body']"
        title = "虹神速報"
      else
        puts('no define key')
      end
       result = [title,mainlc]
       return result
  end

  # 各記事の日付、タイトル、HTMLを取得
  def self.get_contents(item, key)
    link = item.css("link").first.content
    time = Time.parse(item.at("//dc:date").content)

    caption = item.css("title").first.content

     # 記事のHTMLをパース
    page = Nokogiri::HTML(open(link))

     # 各サイトの固有表現(0:サイト名 1:メイン記事位置)
    result = self.ptcl(key)

    # タグ抽出
    tags = [ Scrape.get_tag(result[0]) ]
    # メタ情報があれば追加
    tags.push( Scrape.get_tag(item.at("//dc:subject").content) )
    # はてなキーワードorWikipediaからの名詞がタイトルに含まれていた場合、
    # その名詞をタグに含める
    texts = [caption]
    nouns = KeywordAnalysis.morphological_analysis(texts)
    nouns.keys.each do |noun|
      tags.push(Scrape.get_tag(noun))
    end
    puts tags.inspect

     # メイン記事位置のimgタグについて
    page.css(result[1]).first.css("img").each do |img_items|
      self.get_img(img_items, result[0], caption, time, link, tags)
    end

  end

   # メイン
  def self.scrape
     # 各サイトのURL
    site_url = {
      ika:'http://blog.livedoor.jp/ikasoku_vip/index.rdf',
      aja:'http://blog.livedoor.jp/chihhylove/index.rdf',
      ota:'http://otanews.livedoor.biz/index.rdf',
      nizi:'http://blog.livedoor.jp/nizigami/index.rdf',
    }
    limit = 10

    # 各サイトから抽出
    site_url.keys.each do |key|
      puts 'Extracting : ' + site_url[key]

      # RSSのパース
      xml = Nokogiri::XML(open(site_url[key]))

      # 各item(記事)からコンテンツを取得
      xml.search("item").each_with_index do |item, count|
        # その日に投稿された記事のみ抽出（負荷分散のため）
        #time = Time.parse(item.at("//dc:date").content)
        #next if time.to_date != DateTime.now.to_date

        self.get_contents(item, key)
        break if count >= limit
      end
    end
  end

end
