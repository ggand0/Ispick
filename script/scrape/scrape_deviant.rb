# coding: utf-8
require 'open-uri'

# 公式APIを有するので色々調整出来そう
module Scrape::Deviant
  # -------------------------------------------------------------
  # Use official api
  # boost%3Apopular : 人気順
  # max_age%3A24h   : 24時間以内のimage
  # in%3Amanga      : mangaカテゴリ内のimage
  # documents       : http://b.hatena.ne.jp/pentiumx/deviantart/
  # -------------------------------------------------------------
  ROOT_URL = 'http://backend.deviantart.com/rss.xml?type=deviation&q=boost%3Apopular+max_age%3A24h+in%3Amanga%2Fdigital+anime'

  # アダルトコンテンツであるか判定する
  def self.is_adult(html)
    # アダルトな画像（"mature content"みたいに表現されてる）のデバッグ用url
    # page = 'http://ecchi-enzo.deviantart.com/art/Top-Heavy-ft-Sui-Feng-FREE-435076127'
    # mature画像はクリックをsimulateしないと抽出出来ないくさいので飛ばす
    mature = html.css("div[class='dev-content-mature mzone-main']").first
    if not mature.nil?
      return true
    end
    false
  end

  # 与えられたイラストurlから画像及び関連情報を抽出する
  def self.get_contents(image_data)
    begin
      html = Nokogiri::HTML(open(image_data[:page_url]))
    rescue Exception => e
      Rails.logger.info('Image model saving failed.')
      return
    end

    # アダルト画像を除外
    return if self.is_adult(html)

    # "dev-content-full"とdev-content-normal"で２種類画像ソースが用意されているようだ
    main = html.css("img[class='dev-content-normal']").first
    image_data[:src_url] = main['src']
    puts image_data[:src_url]

    # Stats
    stats_elements = html.css(
      "div[class='dev-right-bar-content dev-metainfo-content dev-metainfo-stats'] dl").first
    stats = {}
    stats_elements.css('dt').each do |node|
      # 数字のみに整形
      count = node.next_element.text      # 次のnodeすなわちddタグを取得
      count.gsub!(/(\n|,| |\(.*)/, '')    # カンマ|空白|(以下 を除去
      stats[node.text] = count.to_i
    end
    image_data[:views] = stats['Views']
    image_data[:favorites] = stats['Favorites']
    #puts stats

    tag_string = html.css("meta[name='keywords']").attr('content').content
    tags = tag_string.split(', ')
    tags = tags.map { |tag| Tag.new(name: tag) }

    # Imageモデル生成＆DB保存
    Scrape::save_image(image_data, tags)
  end

  def self.scrape()
    xml = Nokogiri::XML(open(ROOT_URL))
    puts 'Extracting : ' + ROOT_URL

    xml.css('item').map do |item|
      posted_at = item.css('pubDate').first.content
      posted_at = DateTime.parse(posted_at).utc

      image_data = {
        title: item.css('title').first.content,
        caption: item.css('description').first.content,
        page_url: item.css('link').first.content,
        posted_at: posted_at,
        site_name: 'deviantART',
        module_name: 'Scrape::Deviant'
      }

      self.get_contents(image_data)
    end
  end

  def self.get_stats(page_url)
    begin
      html = Nokogiri::HTML(open(page_url))
    rescue Exception => e
      puts e
      puts 'PAGE_URL: ' + page_url
      Rails.logger.info('Could not open the page.')
      return
    end
    stats_elements = html.css(
      "div[class='dev-right-bar-content dev-metainfo-content dev-metainfo-stats'] dl").first
    stats = {}
    stats_elements.css('dt').each do |node|
      # 数字のみに整形
      count = node.next_element.text      # 次のnodeすなわちddタグを取得
      count.gsub!(/(\n|,| |\(.*)/, '')    # カンマ|空白|(以下 を除去
      stats[node.text] = count.to_i
    end
    { views: stats['Views'], favorites: stats['Favorites'] }
  end

end