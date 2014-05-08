#-*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'natto'


# wikipediaからアニメのキャラクター名を抽出する
module Scrape::Wiki
  require "#{Rails.root}/script/scrape/scrape_characters"
  include Character

  # 日本版Wikipedia URL
  ROOT_URL = 'http://ja.wikipedia.org/wiki/%E3%83%A1%E3%82%A4%E3%83%B3%E3%83%9A%E3%83%BC%E3%82%B8'

  # 関数定義
  # スクレイピングを行う
  def self.scrape
    puts 'Extracting : ' + ROOT_URL

    # 起点となるWikipediaカテゴリページのURL
    # URLはハードコードされているので、修正が必要
    url = [
      'http://ja.wikipedia.org/wiki/Category:2009%E5%B9%B4%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1',
      #'http://ja.wikipedia.org/wiki/Category:2010%E5%B9%B4%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1',
      #'http://ja.wikipedia.org/wiki/Category:2011%E5%B9%B4%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1',
      #'http://ja.wikipedia.org/wiki/Category:2012%E5%B9%B4%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1',
      #'http://ja.wikipedia.org/wiki/Category:2013%E5%B9%B4%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1'
    ]

    # 各URLについて情報を取得
    url.each do |value|
      anime_page = self.get_anime_page(value)
      anime_character_page = Scrape::Wiki::Character.get_anime_character_page(anime_page)
      anime_character = Scrape::Wiki::Character.get_anime_character_name(anime_character_page)
      #self.hash_output(anime_character)  # テスト用
      self.save_to_database(anime_character)
    end

  end


  # アニメ名のハッシュを取得する
  # @param [String] 「20xx年のアニメ一覧」ページのurl
  # @return [Hash] アニメタイトルをkey、該当ページのurlをvalueとするhash
  def self.get_anime_page(url)
    anime_page = {}

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
      return
    rescue SocketError => e
      return
    end

    # アニメ名:アニメのページURLのハッシュを取得
    # カテゴリに分かれたページのURLを取得
    html.css('a').each do |item|
      if /Category/ =~ item['class']  or /CategoryTreeLabel/ =~ item['class']
        category_url = "http://ja.wikipedia.org%s" % [item['href']]
        anime_page[item.inner_text] = self.get_category_anime_page(item.inner_text, category_url)
      end
    end

    # ページ一覧からアニメURLを取得
    html.css('li > a').each do |item|
      if /アカウント/ =~ item.inner_text
        break
      end
      if /年(代)*の(テレビ)*(アニメ|番組)/ =~ item.inner_text or /履歴/ =~ item.inner_text
        next
      end
      if not item.inner_text == '' and not anime_page.has_key?(item.inner_text)
        page_url = "http://ja.wikipedia.org%s" % [item['href']]
        anime_page[item.inner_text] = page_url
      end
    end

    html.css('span > a').each do |item|
      if /年(代)*の(テレビ)*(アニメ|番組)/ =~ item.inner_text
        next
      end
      if not item.inner_text == '' and not anime_page.has_key?(item.inner_text)
        page_url = "http://ja.wikipedia.org%s" % [item['href']]
        anime_page[item.inner_text] = page_url
      end
    end

    anime_page  # Hash
  end


  # カテゴリページ内からアニメのページURLを取得する
  # @param anime_title : String アニメのタイトル
  # @param category_url : String カテゴリページのURL
  def self.get_category_anime_page(anime_title, category_url)
    anime_page_url = ''

    # HTMLページの取得
    begin
      if not category_url == ''
        html = Nokogiri::HTML(open(category_url))
      else
        return
      end
    # 例外処理
    rescue OpenURI::HTTPError => e
      if e.message == '404 Not Found'
        puts '次のURLを開けませんでした'
        puts "URL : #{catergory_url}"
        return
      else
        raise e
      end
    rescue Errno::ENOENT => e
      return
    rescue SocketError => e
      return
    end

    # aタグの取得
    html.css('a').each do |item|
      if anime_title == item.inner_text
        anime_page_url = "http://ja.wikipedia.org%s" % [item['href']]
        break
      end
    end

    anime_page_url  # String
  end


  # ハッシュ内容のファイル出力
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
    input_hash.each do |anime, characters|
      characters.each do |array|
        #array => [鹿目 まどか, かなめ まどか]
        tmp = array.shift(1)                   # tmp => [鹿目 まどか], array => [かなめ まどか]
        next if tmp.nil?
        name_display = tmp.first.gsub(/\s/, '')

        person = Person.create(name: tmp.first, name_display: name_display, name_type: 'Character')

        # 関連キーワードとしてアニメタイトルを追加
        person.keywords.create(word: anime, is_alias: false)

        # Titleレコード追加
        title = Title.create(name: anime)
        title.people << person
        person.titles << title

        # ひらがなもしくは英名をaliasとして追加
        if not array.size == 0
          array.each do |value|
            other_name = value.gsub(/\s/, '')     # => 'かなめまどか'
            person.keywords.create(word: other_name, is_alias: true)
          end
        end

        # keywords保存の例
        #person.keywords.create(word: 'まど', is_alias: true)     # createと同時に保存される
        #person.keywords.create(word: 'ピンク', is_alias: false)

        # mecab使用例
        # ref : http://qiita.com/k-shogo/items/0f8a98c52913c729c7eb
        #mecab = Natto::MeCab.new
        #mecab.parse('まどかだよっ！') do |n|
        #  puts n.surface # => まどか/だ/よ/っ/！　など
        #end
        # =>パフォーマンスに問題あり？ => C++/C#

        person.save!
      end
    end
  end


end
