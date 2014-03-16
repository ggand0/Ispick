#-*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'


# wikipediaからアニメのキャラクター名を抽出する
module Scrape

  # 4chanURL
  ROOT_URL = 'http://ja.wikipedia.org/wiki/%E3%83%A1%E3%82%A4%E3%83%B3%E3%83%9A%E3%83%BC%E3%82%B8'
  
  # 関数定義
  # スクレイピングを行う
  def self.scrap()
    puts 'Extracting : ' + ROOT_URL

    # 起点となるWikipediaカテゴリページのURL
    url = 'http://ja.wikipedia.org/wiki/Category:2011%E5%B9%B4%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1'

    anime_page = self.get_anime_page(url)
    anime_character_page = self.get_anime_character_page(anime_page)
    anime_character = self.get_anime_character_name(anime_character_page)
    self.hash_output(anime_character)
  end


  # アニメ名のハッシュを取得する
  def self.get_anime_page(url)
    anime_page = {}

    begin
      html = Nokogiri::HTML(open(url))
    rescue OpenURI::HTTPError => e
      if e.message == '404 Not Found'
        puts "次のURLを開けませんでした"
        puts "URL : #{url}"
      else
        raise e
      end
    end

    # アニメ名:アニメのページURLのハッシュを取得
    # カテゴリに分かれたページのURLを取得
    html.css('a').each do |item| 
      if /Category/ =~ item["class"]  or /CategoryTreeLabel/ =~ item["class"] then
        category_url = "http://ja.wikipedia.org%s" % [item['href']]
        anime_page[item.inner_text] = self.get_category_anime_page(item.inner_text, category_url)
      end
    end

    # ページ一覧からアニメURLを取得
    html.css('li > a').each do |item| 
      if /アカウント/ =~ item.inner_text then
        break
      end
      if /年(代)*の(テレビ)*(アニメ|番組)/ =~ item.inner_text then
        next
      end
      if item.inner_text != "" and not anime_page.has_key?(item.inner_text) then
        page_url = "http://ja.wikipedia.org%s" % [item['href']]
        anime_page[item.inner_text] = page_url
      end
    end

    html.css('span > a').each do |item|
      if /年(代)*の(テレビ)*(アニメ|番組)/ =~ item.inner_text then
        next
      end
      if item.inner_text != "" and not anime_page.has_key?(item.inner_text) then
        page_url = "http://ja.wikipedia.org%s" % [item['href']]
        anime_page[item.inner_text] = page_url
      end
    end

    anime_page  # Hash
  end


  # カテゴリページ内からアニメのページURLを取得する
  # anime_title : String アニメのタイトル
  # category_url : String カテゴリページのURL
  def self.get_category_anime_page(anime_title, category_url)
    anime_page_url = ""

    begin
      html = Nokogiri::HTML(open(category_url))
    rescue OpenURI::HTTPError => e
        if e.message == '404 Not Found'
          puts "次のURLを開けませんでした"
          puts "URL : #{catergory_url}"
          return
        else
          raise e
        end
    end

    html.css('a').each do |item|
      if anime_title == item.inner_text then
        anime_page_url = "http://ja.wikipedia.org%s" % [item['href']]
        break
      end
    end

    anime_page_url  # String
  end


  # アニメの登場人物ページを取得する
  # page_url : Hash {アニメタイトル => ページURL}
  def self.get_anime_character_page(page_url)
    anime_character_page_url = {}

    # 登場人物・キャラクターページのURLを取得
    page_url.each do |anime, url|

      begin
        html = Nokogiri::HTML(open(url))
      rescue OpenURI::HTTPError => e
        if e.message == '404 Not Found'
          puts '次のURLを開けませんでした'
          puts "URL : #{url}"
          next
        else
          raise e
        end
      end
      
      page_title = html.css('h1[class="firstHeading"] > span')[0].inner_text
      anime = page_title if /#{page_title}/ =~ anime

      # aタグを取得する
      html.css('a').each do |item|
        if /(人物|キャラクター)/ =~ item.inner_text then
          if /(.*)(の|#)(登場)*(人物|キャラクター)(一覧)*/ =~ item.inner_text then
            match_string = $1
            character_page_url = "http://ja.wikipedia.org%s" % [item['href']]
            if /#{match_string}/ =~ anime then
              anime_character_page_url[match_string] = character_page_url
            elsif /#{anime}/ =~ match_string then
              anime_character_page_url[anime] = character_page_url
            end
            break
          end
        end
      end

      # まだハッシュに要素が追加されていない場合の処理
      if not anime_character_page_url.has_key?(anime) then
        anime_character_page_url[anime] = url
      end
    end

    anime_character_page_url.sort # Hash
  end


  # アニメの登場人物を取得する
  def self.get_anime_character_name(wiki_url)
    anime_character = {}

    wiki_url.each do |anime, url|
      name_array = []

      begin
        html = Nokogiri::HTML(open(url))
      rescue OpenURI::HTTPError => e
        if e.message == '404 Not Found'
          puts '次のURLを開けませんでした'
          puts "URL : #{url}"
          next
        else
          raise e
        end
      end

      html.css('h2').each do |item|
        if /(主な|主要|登場)*(人物|キャラクター)(一覧)*/ =~ item.inner_text then
          current = item.next_element
          while true
            if current.name == 'dl' then
              current.css('dt').each do |dt|
                if dt.inner_text != '' then
                  tmp = dt.inner_text
                  if /^\(.*\)$/ =~ tmp or /【.*】/ =~ tmp or /.+アニメ版/ =~ tmp or /.+時代/ =~ tmp or /.+設定/ =~ tmp then
                    next
                  end
                  tmp.gsub!(/\[.*\]/, '')
                  tmp.gsub!(/,/, '')
                  name_array.push(tmp)
                end
              end
            elsif current.name == 'h2' or current.name == 'script'
              break
            end
            current = current.next_element
          end
        end
      end

      anime_character[anime] = name_array
    end

    anime_character  # Hash
  end


  # ハッシュ内容のファイル出力
  def self.hash_output(input_hash)
    f = open("sample.txt", "w")
    input_hash.each do |key, array|
      f.write(">> #{key}\n")
      array.each do |value|
        f.write("#{value}\n")
      end
      f.write("\n")
    end
  end

end


Scrape.scrap()
