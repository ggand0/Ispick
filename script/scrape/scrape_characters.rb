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
          elsif /#{anime}/ =~ match_string
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
  # @param page_url : Hash {アニメタイトル => ページURL}
  def self.get_anime_character_page(page_url)
    anime_character_page_url = {}

    # 登場人物・キャラクターページのURLを取得
    page_url.each do |anime, url|
      next if url.empty?

      # 日本語タイトルをkeyとする
      html_ja = Scrape::Wiki.open_html url[:ja]
      html_en = Scrape::Wiki.open_html url[:en]
      page_title = html_ja.css('h1[class="firstHeading"] > span')[0].inner_text
      anime_title = page_title if /#{page_title}/ =~ anime_title

      page_url_ja = self.get_character_page_ja anime_title, url, html_ja
      page_url_en = self.get_character_page_en anime_title, url, html_en
      anime_character_page_url[anime_title] = { ja: page_url_ja, en: page_url_en }

      # まだハッシュに要素が追加されていない場合の処理
      #unless anime_character_page_url.has_key?(anime_title)
      #  anime_character_page_url[anime_title] = url
      #end
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
      html = Scrape::Wiki.open_html url

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
end