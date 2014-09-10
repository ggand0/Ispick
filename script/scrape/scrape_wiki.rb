#-*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'natto'


# Scrape anime characters names from Wikipedia
# wikipediaからアニメのキャラクター名を抽出する
module Scrape::Wiki
  require "#{Rails.root}/script/scrape/scrape_characters"
  require "#{Rails.root}/script/scrape/scrape_game_characters"
  include Character
  include GameCharacter

  ROOT_URL = 'http://en.wikipedia.org/wiki/Main_Page'

  def self.scrape_all
    puts "Extracting: #{ROOT_URL}"

    # The array of Wikipedia pages that list up anime titles.
    # アニメタイトル一覧ページの配列
    url = [
      'http://en.wikipedia.org/wiki/Category:2014_anime_television_series'
    ]

    url.each do |value|
      # Scrape anime titles and urls pairs.
      # アニメの概要ページのURL/タイトルのHashを取得
      anime_page = self.get_anime_page(value)

      # Get another page that describes characters. If not, get overview page instead.
      # 登場人物の一覧ページの配列を取得、一覧ページが無い場合は概要ページを配列に追加
      anime_character_page = Scrape::Wiki::Character.get_anime_character_page(anime_page)

      # From character info pages, get character names an array.
      # キャラクタ名の一覧配列を取得
      anime_character = Scrape::Wiki::Character.get_anime_character_name(anime_character_page)

      # Finally save them to the database, into the people table.
      # キャラクタ名をDBヘ保存
      #self.hash_output(anime_character)
      self.save_to_database(anime_character)
    end

    # Option: Scrape major game character names
    #self.scrape_wiki_for_game_characters
  end

  # Scrape titles only
  def self.scrape_titles
    puts "Extracting: #{ROOT_URL}"

    # The array of Wikipedia pages that list up anime titles.
    url = [ 'http://en.wikipedia.org/wiki/Category:2014_anime_television_series' ]

    url.each do |value|
      anime_pages = self.get_anime_page(value)
      puts anime_pages.count
    end
  end


  # アニメ名のハッシュを取得する
  # @param [String] 「20xx年のアニメ一覧」ページのurl
  # @return [Hash] アニメタイトルをkey、該当ページのurlをvalueとするhash
  def self.get_anime_page(url, logging=true)
    anime_page = {}
    html = self.open_html url

    # ページ一覧からアニメURLを取得
    # liタグ->aタグの順にネストされているパターン
    html.css("div[id='mw-pages']").css('li > a').each do |item|
      puts(item.inner_text)
      if not item.inner_text.empty? and not anime_page.has_key?(item.inner_text)
        page_url_en = "http://en.wikipedia.org#{item['href']}"
        page_url_ja = self.get_anime_page_ja page_url_en

        puts page_url_ja if logging
        anime_page[item.inner_text] = { ja: page_url_ja, en: page_url_en }
      end
    end

    anime_page
  end


  # 英語版ページへのリンクがある場合そのページurlを返す
  # @param [String] 日本語版ページのurl
  # @return [String] 英語版ページのurl
  def self.get_anime_page_en(anime_page)
    html = self.open_html anime_page
    return if html.nil?

      # 日本語ページに登場キャラクターがいない
     if !self.detect_having_characters(html)
      return 'no_characters'
     end

    item = html.css("li[class='interlanguage-link interwiki-en']").first

    # liタグ内のaタグのリンクを調べる
    if item.nil?
      return ''
    else
      url = item.css('a').first.attr('href')
      return "http:#{url}"
    end
  end

  def self.get_anime_page_ja(anime_page)
    html = self.open_html anime_page
    return if html.nil?

    item = html.css("li[class='interlanguage-link interwiki-ja']").first

    # liタグ内のaタグのリンクを調べる
    if item.nil?
      return ''
    else
      url = item.css('a').first.attr('href')
      return "http:#{url}"
    end
  end


  # HTMLページを開いてNokogiriのHTMLオブジェクトを返す。
  # 例外が発生した場合はnilを返す
  # @param [String] 対象url
  # @return [Nokogiri::HTML] NokogiriでパースされたHTMLオブジェクト
  def self.open_html(url)
    begin
      html = Nokogiri::HTML(open(url))
    rescue OpenURI::HTTPError => e
      if e.message == '404 Not Found'
        puts '次のURLを開けませんでした'
        puts "URL : #{url}"
      else
        raise e
      end
    rescue Errno::ENOENT => e
      return puts e
    rescue SocketError => e
      return puts e
    rescue => e
      return puts e
    end
  end


  # ハッシュ内容のファイル出力(未使用)
  # @param [Hash] keyがアニメタイトル、valueが登場キャラクタの配列であるようなHash
  def self.hash_output(input_hash)
    f = open("sample.txt", "a")
    input_hash.each do |anime, characters|
      f.write(">> #{anime}\n")
      characters.each do |array|
        f.write("[")
        array.each do |value|
          f.write("#{value}, ")
        end
        f.write("]\n")
      end
      f.write("\n")
    end
  end


  # キャラクタ情報をparseしてPeopleテーブルへ保存する
  # @param [Hash] keyがアニメタイトル、valueが登場キャラクタの配列であるようなHash
  def self.save_to_database(input_hash)
    puts "Saving character names to database..."

    input_hash.each do |anime, value|
      next if value.nil? or value[:characters].nil?
      puts "anime=#{anime}"
      puts "value=#{value}"

      title_en = value[:title_en]
      value[:characters].each do |name_hash|
        # {:name=>"鹿目 まどか", :query=>"鹿目まどか", :_alias=>"かなめ まどか", :en=>"Madoka Kaname"}
        person = Person.create(
          name: name_hash[:query],
          name_display: name_hash[:name],
          name_english: name_hash[:en],
          name_type: 'Character'
        )

        # 関連キーワードとしてアニメタイトルを追加
        keyword = self.get_keyword(anime, false)
        person.keywords << keyword

        # Titleレコード追加
        title = self.get_title(value[:title_ja], value[:title_en])
        person.titles << title

        # よみがなをaliasとして追加
        #keyword = self.get_keyword(name_hash[:_alias], true)
        #person.keywords << keyword

        # keywords保存の例
        #person.keywords.create(name: 'まど', is_alias: true)     # createと同時に保存される
        #person.keywords.create(name: 'ピンク', is_alias: false)

        # mecab使用例
        # ref : http://qiita.com/k-shogo/items/0f8a98c52913c729c7eb
        #mecab = Natto::MeCab.new
        #mecab.parse('まどかだよっ！') do |n|
        #  puts n.surface # => まどか/だ/よ/っ/！　など
        #end
        # =>パフォーマンスに問題あり？ => C++/C#

        person.save
      end
    end
  end

  # 既存のKeywordレコードを調べて、既存のものか新規作成してインスタンスを返す
  # @param name [String]
  # @param is_alias [Boolean]
  # @return [Keyword]
  def self.get_keyword(name, is_alias)
    keyword = Keyword.where(name: name)
    keyword.empty? ? Keyword.new(name: name, is_alias: is_alias) : keyword.first
  end

  # 既存のTitleレコードを調べて、既存のものか新規作成してインスタンスを返す
  # @param name [String]
  # @param name_en [Boolean]
  # @return [Title]
  def self.get_title(name, name_en)
    title = Title.where(name: name)
    title.empty? ? Title.new(name: name, name_english: name_en) : title.first
  end

end
