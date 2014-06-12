#-*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'natto'

module Scrape::Wiki::Character
  # アニメの登場人物ページを取得する
  # @param page_hash : Hash { { ja: '日本語概要ページ', en: '英語概要ページ' } => ページURL}
  def self.get_anime_character_page(page_hash, logging=true)
    puts 'Extracting character pages...'
    anime_character_page_url = {}

    # 登場人物・キャラクターページのURLを取得
    page_hash.each do |anime_title, url|
      next if url[:ja].empty?                     # str.empty?はstr=''だったらtrueを返す

      html_ja = Scrape::Wiki.open_html url[:ja]   # まずは日本語の概要ページを開く
      next if html_ja.nil?                        # obj.nil?はobj=nilだったらtrueを返すメソッド
      html_en = Scrape::Wiki.open_html url[:en]


      # 抽出してきたタイトルと、アニメタイトルを比べて冗長でない方を採用
      page_title = html_ja.css('h1[class="firstHeading"]').first.content
      title_ja = page_title if /#{page_title}/ =~ anime_title
      page_url_ja = self.get_character_page_ja(title_ja, url[:ja], html_ja)

      # 英語版の登場人物一覧ページを取得する
      if (not url[:en].empty?) and (not html_en.nil?)
        title_en = html_en.css('h1[class="firstHeading"]').first.content
        page_url_en = self.get_character_page_en(title_en, url[:en], html_en)
      else
        page_url_en = { title: title_ja, url: '' } # 日本語タイトルをkeyとする
      end

      # アニメタイトルがkey、それぞれの言語の人物一覧ページのHashがvalueであるようなペアを追加
      anime_character_page_url[title_ja] = { ja: page_url_ja[:url], en: page_url_en[:url] }#anime_title
      #puts anime_character_page_url[title_ja] if logging
      puts anime_character_page_url.to_a.last if logging
    end

    # 辞書順にHashをソートして返す
    puts '-----------------------------------'
    puts anime_character_page_url
    anime_character_page_url.delete_if { |k, v| v.empty? or v.nil? or k.empty? or k.nil? }
    puts '-----------------------------------'
    Hash[ anime_character_page_url.sort_by{|k,v| k} ]
  end


  # 英語の概要ページから、登場人物一覧ページを取得する
  # @param [String] アニメのタイトル
  # @param [String] 概要ページのURL
  # @param [Nokogiri::HTML] 概要ページを開いて生成したHTMLオブジェクト
  # @return [Hash] アニメタイトルをkey、人物一覧ページをvalueとするHash
  def self.get_character_page_en(anime_title, url, html)
    html.css('a').each do |item|
      # 'List of xxx characters'というテキストを持つaタグから判断する
      if /(characters|Characters)/ =~ item.inner_text
        if /(List of |list of )(.*)( characters| Characters)/ =~ item.inner_text
          match_string = $2               # 正規表現内２つ目のグループ、(.*)に相当するマッチした文字列を取得、アニメタイトルに相当
          match_string.gsub!(/\(.*/, '')  # 整形
          character_page_url = "http://en.wikipedia.org#{item['href']}" # 人物一覧ページURL取得

          if /#{match_string}/ =~ anime_title
            return { title: match_string, url: character_page_url }
          elsif /#{anime_title}/ =~ match_string
            return { title: anime_title, url: character_page_url }
          end

          break # Matchしなかった場合
        end
      end

    end

    # Matchしなかった場合は、同ページに一覧があると判断
    { title: anime_title, url: url }
  end

  # 日本語の概要ページから、登場人物一覧ページを取得する
  # @param [String] アニメのタイトル
  # @param [String] 概要ページのURL
  # @param [Nokogiri::HTML] 概要ページを開いて生成したHTMLオブジェクト
  # @return [Hash] アニメタイトルをkey、人物一覧ページをvalueとするHash
  def self.get_character_page_ja(anime_title, url, html)
    html.css('a').each do |item|
      # get_character_page_enと同様
      if /(人物|キャラクター)/ =~ item.inner_text
        if /(.*)(の|#)(登場)*(人物|キャラクター)(一覧)*/ =~ item.inner_text
          match_string = $1
          match_string.gsub!(/\(.*/, '')
          character_page_url = "http://ja.wikipedia.org%s" % [item['href']]

          if /#{match_string}/ =~ anime_title
            return { title: match_string, url: character_page_url  }
          elsif /#{anime_title}/ =~ match_string
            return { title: anime_title, url: character_page_url }
          end

          break
        end
      end
    end

    # Matchしなかった場合は、同ページに一覧があると判断
    { title: anime_title, url: url }
  end



  # アニメの登場人物を取得する
  # @param [Hash] { 'An anime title' => { ja: url, en: url } }
  # @return [Hash] キャラクタ一覧
  def self.get_anime_character_name(wiki_url, logging=true)
    puts 'Extracting character names...'
    anime_character = {}

    # 与えられたWikipediaのURLから登場人物の詳細ページを抜き出す
    wiki_url.each do |anime_title, url|
      html_ja = Scrape::Wiki.open_html url[:ja]
      html_en = Scrape::Wiki.open_html url[:en]
      next if html_ja.nil?

      # => [ ['鹿目 まどか', 'かなめ まどか'], ... ]
      name_ja = self.get_character_name_ja(anime_title, html_ja) if html_ja

      # 英名追加後のHashのArrayが返される
      if html_en
        name_array = self.get_character_name_en(anime_title, html_en, name_ja)
      else
        name_array = name_ja
      end

      puts name_array if logging
      anime_character[anime_title] = name_array
    end

    anime_character
  end

  # 日本語の登場人物一覧ページから、キャラクタ名の配列を生成する
  # @param [String] アニメタイトル
  # @param [Nokogiri::HTML] 人物一覧ページを開いて生成したHTMLオブジェクト
  # @return [Array] キャラクタ情報のHashを要素とするArray
  def self.get_character_name_ja(anime_title, html)
    name_array = []

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

                # '(', '（'のどれかで括られているキャラクタ名の場合
                # 鹿目 まどか （かなめ まどか）などの表記が該当
                if /(.*?)[\(（](.*?)[\)）]/ =~ tmp
                  name = $1
                  _alias = $2
                  tmp_hash = { name: name, query: name.gsub(/\s/, ''), _alias: _alias }
                  name_array.push(tmp_hash)
                # それ以外：「キュウべえ」など
                else
                  tmp_hash = { name: tmp, query: tmp.strip, _alias: '' }
                  name_array.push(tmp_hash)
                end
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

    # 条件を満たした場合、Arrayに値を追加
    if not anime_title.empty? and not name_array.size == 0
      return name_array
    end
  end

  # 日本語のキャラクタ一覧とマッチするキャラクタかどうか調べる
  # @param [String] '(鹿目 まどか, Kaname Madoka)'など括弧内の記述部
  # @return [Hash] { match: boolean, list: 削除後のcharacters_list }
  def self.match_character_name(name_string, characters_list)
    return '' if characters_list.nil?

    characters_list.each do |character_name|
      if /#{character_name[:name]}/ =~ name_string
        return character_name
      end
    end
    ''
  end

  def self.convert_macrons(name)
    name.gsub!(/ā/, 'aa')
    name.gsub!(/ī/, 'ii')
    name.gsub!(/ū/, 'uu')
    name.gsub!(/ē/, 'ei')
    name.gsub!(/ō/, 'ou')
    name.gsub!(/Ā/, 'Aa')
    name.gsub!(/Ī/, 'Ii')
    name.gsub!(/Ū/, 'Uu')
    name.gsub!(/Ē/, 'Ei')
    name.gsub!(/Ō/, 'Ou')
    name
  end

  def self.add_character_name(name, res, name_array, characters_list)
    if not res.empty?
      characters_list.delete(res)
      res[:en] = self.convert_macrons(name)
      name_array.push(res)
    end

    [ name_array, characters_list ]
  end

  # 英語の登場人物一覧ページから、キャラクタ名の配列を生成する
  # @param [String] アニメタイトル（日本語）
  # @param [Nokogiri::HTML] 人物一覧ページを開いて生成したHTMLオブジェクト
  # @param [Array] キャラクタ情報のHashを要素とするArray（和名）
  # @return [Array] キャラクタ情報のHashを要素とするArray
  def self.get_character_name_en(anime_title, html, characters_list)
    name_array = []

    # h2タグを抜き出す
    html.css('h2').each do |item|
      if /(main|Main)*(characters|Characters)/ =~ item.inner_text
        current = item.next_element

        # dtタグの抽出
        while true
          if current.respond_to?(:name) and current.name == 'dl'
            current.css('dt').each do |dt|
              next if dt.inner_text.empty?

              tmp = dt.inner_text
              tmp.gsub!(/\?/, '')
              tmp_array = []

              # Leysritt (リーゼリット Rīzeritto?) and Sella (セラ Sera?)
              if /(.*?) \((.*?)\) and (.*?) \((.*?)\)/ =~ tmp
                tmp_array = tmp.split(' and ')
                names = [ $1, $2, $3, $4 ]

=begin

                res = self.match_character_name(names[1], characters_list)
                name_array, characters_list = self.add_character_name(
                  names[0], res, name_array, characters_list) if not res.empty?

                res = self.match_character_name(names[3], characters_list)
                name_array, characters_list = self.add_character_name(
                    names[2], res, name_array, characters_list) if not res.empty?
=end
                res = self.match_character_name(names[1], characters_list)
                if not res.empty?
                  characters_list.delete(res)
                  res[:en] = self.convert_macrons(names[0])
                  name_array.push(res)
                end
                res = self.match_character_name(names[3], characters_list)
                if not res.empty?
                  characters_list.delete(res)
                  res[:en] = self.convert_macrons(names[2])
                  name_array.push(res)
                end

              # Yūri (ユウリ?) / Airi Anri (杏里 あいり Anri Airi?)
              elsif /(.*?) \((.*?)\) \/ (.*?) \((.*?)\)/ =~ tmp
                tmp_array = tmp.split(' / ')
                names = [ $1, $2, $3, $4 ]

=begin
                res = self.match_character_name(names[1], characters_list)
                name_array, characters_list = self.add_character_name(
                  names[0], res, name_array, characters_list) if not res.empty?

                res = self.match_character_name(names[3], characters_list)
                name_array, characters_list = self.add_character_name(
                    names[2], res, name_array, characters_list) if not res.empty?
                res = self.match_character_name(names[1], characters_list)
=end
                res = self.match_character_name(names[1], characters_list)
                if not res.empty?
                  characters_list.delete(res)
                  res[:en] = self.convert_macrons(names[0])
                  name_array.push(res)
                end
                res = self.match_character_name(names[3], characters_list)
                if not res.empty?
                  characters_list.delete(res)
                  res[:en] = self.convert_macrons(names[2])
                  name_array.push(res)
                end

              else
                # Madoka Kaname (鹿目 まどか Kaname Madoka?)
                if /(.*?) \((.*?)\)/ =~ tmp
                  names = [ $1, $2 ]

                  res = self.match_character_name(names[1], characters_list)
                  #name_array, characters_list = self.add_character_name(
                  #  names[0], res, name_array, characters_list) if not res.empty?
                  if not res.empty?
                    characters_list.delete(res)
                    res[:en] = self.convert_macrons(names[0])
                    name_array.push(res)
                  end
                else
                  res = self.match_character_name(tmp, characters_list)
                  #name_array, characters_list = self.add_character_name(
                  #  tmp, res, name_array, characters_list) if not res.empty?
                  if not res.empty?
                    characters_list.delete(res)
                    res[:en] = self.convert_macrons(tmp)
                    name_array.push(res)
                  end
                end

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
    if not anime_title == '' and not name_array.size == 0
      # 英名があるキャラクタ名リスト＋和名のみのリスト
      return name_array + characters_list
    end
  end


end