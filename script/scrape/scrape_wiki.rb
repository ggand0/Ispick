#-*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'natto'


# wikipediaからアニメのキャラクター名を抽出する
module Scrape::Wiki

  # 日本版Wikipedia URL
  ROOT_URL = 'http://ja.wikipedia.org/wiki/%E3%83%A1%E3%82%A4%E3%83%B3%E3%83%9A%E3%83%BC%E3%82%B8'

  # 関数定義
  # スクレイピングを行う
  def self.scrape()
    puts 'Extracting : ' + ROOT_URL

    # 起点となるWikipediaカテゴリページのURL
    # URLはハードコードされているので、修正が必要
    url = [
      'http://ja.wikipedia.org/wiki/Category:2009%E5%B9%B4%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1',
      'http://ja.wikipedia.org/wiki/Category:2010%E5%B9%B4%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1',
      'http://ja.wikipedia.org/wiki/Category:2011%E5%B9%B4%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1',
      'http://ja.wikipedia.org/wiki/Category:2012%E5%B9%B4%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1',
      'http://ja.wikipedia.org/wiki/Category:2013%E5%B9%B4%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1'
    ]

    # 各URLについて情報を取得
    url.each do |value|
      anime_page = self.get_anime_page(value)
      anime_character_page = self.get_anime_character_page(anime_page)
      anime_character = self.get_anime_character_name(anime_character_page)
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


  # アニメの登場人物ページを取得する
  # @param page_url : Hash {アニメタイトル => ページURL}
  def self.get_anime_character_page(page_url)
    anime_character_page_url = {}

    # 登場人物・キャラクターページのURLを取得
    page_url.each do |anime, url|
      # HTMLページの取得
      begin
        if not url == ''
          html = Nokogiri::HTML(open(url))
        else
          next
        end
      # 例外処理
      rescue OpenURI::HTTPError => e
        if e.message == '404 Not Found'
          puts '次のURLを開けませんでした'
          puts "URL : #{url}"
          next
        else
          raise e
        end
      rescue Errno::ENOENT => e
        puts '次のURLを開けませんでした'
        puts "URL : #{url}"
        next
      rescue SocketError => e
        puts '次のURLを開けませんでした'
        puts "URL : #{url}"
        next
      end

      page_title = html.css('h1[class="firstHeading"] > span')[0].inner_text
      anime = page_title if /#{page_title}/ =~ anime

      # aタグの取得
      html.css('a').each do |item|
        if /(人物|キャラクター)/ =~ item.inner_text
          if /(.*)(の|#)(登場)*(人物|キャラクター)(一覧)*/ =~ item.inner_text
            match_string = $1
            match_string.gsub!(/\(.*/, '')
            character_page_url = "http://ja.wikipedia.org%s" % [item['href']]
            if /#{match_string}/ =~ anime
              anime_character_page_url[match_string] = character_page_url
            elsif /#{anime}/ =~ match_string
              anime_character_page_url[anime] = character_page_url
            end
            break
          end
        end
      end

      # まだハッシュに要素が追加されていない場合の処理
      unless anime_character_page_url.has_key?(anime)
        anime_character_page_url[anime] = url
      end
    end

    anime_character_page_url.sort # Hash
  end


  # アニメの登場人物を取得する
  def self.get_anime_character_name(wiki_url)
    # 空のハッシュ
    anime_character = {}

    # 与えられたWikiのURLから登場人物の詳細ページを抜き出す
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
      rescue Errno::ENOENT => e
        next
      rescue SocketError => e
        next
      end

      # h2タグを抜き出す
      html.css('h2').each do |item|
        if /(主な|主要|登場)*(人物|キャラクター)(一覧)*/ =~ item.inner_text
          current = item.next_element

          # タグの抽出
          while true
            if current.respond_to?(:name) and current.name == 'dl'
              # dtタグの抽出
              current.css('dt').each do |dt|
                if not dt.inner_text == ''
                  tmp = dt.inner_text
                  tmp_array = []
                  if /^\(.*\)$/ =~ tmp or /^【.*】$/ =~ tmp
                    next
                  elsif /.*アニメ版/ =~ tmp or /.*漫画版/ =~ tmp or /.*時代/ =~ tmp or /.*設定/ =~ tmp
                    next
                  end
                  tmp.gsub!(/\[.*\]/, '')
                  tmp.gsub!(/,/, '')
                  if /(.*?)[\(（](.*?)[\)）]/ =~ tmp
                    first_array = $1.split('/')
                    second_array = $2.split('/')
                    first_array.map! { |value| value.strip }
                    second_array.map! { |value| value.strip }
                    tmp_array += first_array
                    tmp_array += second_array
                  else
                    tmp_array.push(tmp.strip)
                  end
                  name_array.push(tmp_array)
                end
              end
            elsif current.respond_to?(:name) and (current.name == 'h2' or current.name == 'script')
              break
            end

            # next_elementが存在するかどうかの判定
            if current.respond_to?(:next_element)
              current = current.next_element
            else
              break
            end
          end

        end
      end

      # 条件を満たした場合、ハッシュに値を追加
      if not anime == '' and not name_array.size == 0
        anime_character[anime] = name_array
      end
    end

    anime_character  # Hash
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
