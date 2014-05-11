#-*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'natto'

module Scrape::Wiki::Character
  def self.get_character_page_en(anime_title, url, html)
    # aタグの取得
    html.css('a').each do |item|
      if /(characters|Characters)/ =~ item.inner_text
        if /(List of |list of )(.*)( characters| Characters)/ =~ item.inner_text
          match_string = $2
          match_string.gsub!(/\(.*/, '')
          character_page_url = "http://.wikipedia.org%s" % [item['href']]
          if /#{match_string}/ =~ anime_title
            return { title: match_string, url: character_page_url }
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

  def self.get_character_page_ja(anime_title, url, html)
    # aタグの取得
    html.css('a').each do |item|
      if /(人物|キャラクター)/ =~ item.inner_text
        if /(.*)(の|#)(登場)*(人物|キャラクター)(一覧)*/ =~ item.inner_text
          match_string = $1
          match_string.gsub!(/\(.*/, '')
          character_page_url = "http://ja.wikipedia.org%s" % [item['href']]
          if /#{match_string}/ =~ anime_title
            #anime_character_page_url[match_string] = character_page_url
            return { title: match_string, url: character_page_url  }
          elsif /#{anime_title}/ =~ match_string
            #anime_character_page_url[anime] = character_page_url
            return { title: anime_title, url: character_page_url }
          end
          break
        end
      end
    end

    # Matchしなかった場合は、同ページに一覧があると判断
    { title: anime_title, url: url }
  end

  # アニメの登場人物ページを取得する
  # @param page_hash : Hash {アニメタイトル => ページURL}
  def self.get_anime_character_page(page_hash)
    anime_character_page_url = {}

    # 登場人物・キャラクターページのURLを取得
    page_hash.each do |anime_title, url|
      next if url[:ja].empty?

      # 日本語タイトルをkeyとする
      html_ja = Scrape::Wiki.open_html url[:ja]
      page_title = html_ja.css('h1[class="firstHeading"] > span')[0].inner_text
      anime_title = page_title if /#{page_title}/ =~ anime_title

      page_url_ja = self.get_character_page_ja anime_title, url, html_ja

      if not url[:en].empty?
        html_en = Scrape::Wiki.open_html url[:en]
        page_url_en = self.get_character_page_en anime_title, url, html_en
      else
        page_url_en = ''
      end
      anime_character_page_url[anime_title] = { ja: page_url_ja, en: page_url_en }
    end

    #anime_character_page_url.sort # Hash
    Hash[ anime_character_page_url.sort_by{|k,v| k} ]
  end

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
                  puts tmp
                  first_array = $1.split('/')#／／/
                  second_array = $2.split('/')
                  first_array.map! { |value| value.strip }
                  second_array.map! { |value| value.strip }
                  tmp_array += first_array
                  tmp_array += second_array
                # それ以外：「キュウべえ」など
                else
                  #puts tmp
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
    if not anime_title == '' and not name_array.size == 0
      #anime_character[anime] = name_array
      return name_array
    end
  end

  # @param [String] 'Madoka Kaname (鹿目 まどか, Kaname Madoka)
  def self.match_character_name(name_string, characters_list)
    characters_list.each do |character_name|
      if character_name =~ name_string
        characters_list.delete(character_name)
        return { match: true, list: characters_list }
      end
    end
    { match: false, list: characters_list }
  end

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

              if not dt.inner_text == ''
                tmp = dt.inner_text
                tmp_array = []
                #result = self.match_character_name(tmp, characters_list)
                #characters_list = result[:list]

                tmp.gsub!(/\?/, '')

                # Leysritt (リーゼリット Rīzeritto?) and Sella (セラ Sera?)
                #if /(.*?)\((.*?)\)( |\s)and( |\s)(.*?)\((.*?)\)/ =~ tmp
                if /(.*?) \((.*?)\) and (.*?) \((.*?)\)/ =~ tmp
                  tmp_array = tmp.split(' and ')

                  name_array.push($1)
                  name_array.push($3)
                # Yūri (ユウリ?) / Airi Anri (杏里 あいり Anri Airi?)
                elsif /(.*?) \((.*?)\) \/ (.*?) \((.*?)\)/ =~ tmp
                  tmp_array = tmp.split(' / ')

                  name_array.push($1)
                  name_array.push($3)
                else
                  # Madoka Kaname (鹿目 まどか Kaname Madoka?)
                  if /(.*?) \((.*?)\)/ =~ tmp
                  #if result[:match]
                    tmp_array += $1.split('/')
                  else
                    tmp_array.push(tmp.strip)
                  end
                  name_array.push(tmp_array)
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
      #anime_character[anime] = name_array
      return name_array
    end
  end

  # アニメの登場人物を取得する
  # @param [Hash] { 'An anime title' => { ja: url, en: url } }
  # @return [Hash] キャラクタ一覧
  def self.get_anime_character_name(wiki_url)
    anime_character = {}

    # 与えられたWikipediaのURLから登場人物の詳細ページを抜き出す
    wiki_url.each do |anime_title, url|
      name_array = []
      html = Scrape::Wiki.open_html url

      name_ja = self.get_character_name_ja anime_title, html
      name_en = self.get_character_name_en anime_title, html
      anime_character[anime_title] = { ja: name_ja, en: name_en }
    end

    anime_character
  end
end