#-*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'natto'

module Scrape::Wiki::GameCharacter

  # ゲームの登場人物を取得する
  # @param [Hash] { 'An anime title' => { ja: url, en: url } }
  # @return [Hash] キャラクタ一覧
  def self.get_game_character_name(wiki_url, logging=true)
    puts 'Extracting character names...'
    anime_character = {}

    # 与えられたWikipediaのURLから登場人物の詳細ページを抜き出す
    wiki_url.each do |anime_title, url|
      html_ja = Scrape::Wiki.open_html url[:ja]
      html_en = Scrape::Wiki.open_html url[:en]
      next if html_ja.nil?

      # => [ ['鹿目 まどか', 'かなめ まどか'], ... ]
      name_ja = self.get_game_character_name_ja(anime_title, html_ja) if html_ja
      #puts(name_ja)

      # 英名追加後のHashのArrayが返される
      if html_en
        name_array = self.get_game_character_name_en(anime_title, html_en, name_ja)
            # 英名追加失敗時
          if(name_array==nil and name_ja != nil)
            name_array=name_ja
          end
      else
        name_array = name_ja
      end

      puts name_array if logging
      anime_character[anime_title] = { title_en: url[:title_en], characters: name_array }
    end

    anime_character
  end


  # 日本語の登場人物一覧ページから、キャラクタ名の配列を生成する
  # @param [String] ゲームタイトル
  # @param [Nokogiri::HTML] 人物一覧ページを開いて生成したHTMLオブジェクト
  # @return [Array] キャラクタ情報のHashを要素とするArray
  def self.get_game_character_name_ja(anime_title, html)
    name_array = []

     # 専用ページ
    if /(主な|主要|登場)*(人物|キャラクター)(一覧)*/ =~ html.css("title").first.content
      html.css("dt").each do |item|
          #()書きなどの除去　~ ()やカンマ
        name = item.content.gsub(/(\(|（).*(\)|）)|((,|、).*)/,"")
          #スペースの除去
        query = name.gsub(/ |　/,"")
          #()書きがあればaliasに
        if( /(\(|（).*(\)|）)/ =~ item.content ) then
          _alias = item.content.gsub(/.*(\(|（)/,"")
          _alias = _alias.gsub(/\)|）/,"")
          _alias = _alias.gsub(/(,|、).*/,"")
        else
          _alias = ""
        end
        #puts("name:"+name.to_s+"  query:"+query.to_s+"  alias:"+_alias.to_s)

        #hashにしてname_array
        name_hash = { name: name, query: query, _alias: _alias }
        name_array.push(name_hash)
      end

    else
       # 見出しを確認
      html.css("span[class='mw-headline']").each do |item2|
        # 見出しがキャラクター一覧を表す語であれば、その親タグ以降のdlタグに注目
        if /(主な|主要|登場)*(人物|キャラクター)(一覧)*/ =~ item2.inner_text

            # 自分自身が終わった、その次のタグ。階層を無視した次のタグ
            # <h2> => <h3>など。
            current = item2.parent.next_element

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
                        # [] の除去
                    tmp.gsub!(/\[.*\]/, '')
                        # , の除去
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
              elsif current.respond_to?(:name) and (current.name == item2.parent.name or current.name == 'script')
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
    end

     # 条件を満たした場合、Arrayに値を追加
    if not anime_title.empty? and not name_array.size == 0
      return name_array
    end
  end


  # 英語の登場人物一覧ページから、キャラクタ名の配列を生成する
  # @param [String] ゲームタイトル（日本語）
  # @param [Nokogiri::HTML] 人物一覧ページを開いて生成したHTMLオブジェクト
  # @param [Array] キャラクタ情報のHashを要素とするArray（和名）
  # @return [Array] キャラクタ情報のHashを要素とするArray
  def self.get_game_character_name_en(anime_title, html, characters_list)
    name_array = []
    htag = nil
    # h2タグに相当するタグを検出
    html.css("span[class='mw-headline']").each do |item|
      if /((main|Main)*(characters|Characters))|((characters|Characters)*(of).*)/ =~ item.inner_text
        htag = item.parent.name
        break
      end
    end

     # 英名ページにキャラクター一覧に該当する部分がある
    puts htag
    if !htag.nil?
      # h2タグを抜き出す
      html.css(htag).each do |item|
        begin
          tmp, characters_list = self.scrape_game_character_name_en(anime_title, html, characters_list, item)
          name_array += tmp
        rescue => e
          puts "#{anime_title}: #{item}#{characters_list}"
          puts e
        end
      end

      # 条件を満たした場合、ハッシュに値を追加
      if not anime_title == '' and not name_array.size == 0
        # 英名があるキャラクタ名リスト＋和名のみのリスト
        return name_array + characters_list
      end
    else
      return characters_list
    end
  end

  def self.scrape_game_character_name_en(anime_title, html, characters_list, item)
    name_array = []

    if /((main|Main)*(characters|Characters))|((characters|Characters)*(of).*)/ =~ item.inner_text
      current = item.next_element

      # dtタグの抽出
      while true
        if current.respond_to?(:name) and (current.name == 'dl' or current.name=='ul')
          if(current.name == 'dl')
            tmp_tag = 'dt'
          else
            tmp_tag = 'li'
          end

          current.css(tmp_tag).each do |dt|
            next if dt.inner_text.empty?

            tmp = self.have_name_ja(dt,characters_list)
            #tmp = dt.inner_text
            tmp.gsub!(/\?/, '')
            tmp_array = []

            # Leysritt (リーゼリット Rīzeritto?) and Sella (セラ Sera?)
            if /(.*?) \((.*?)\) and (.*?) \((.*?)\)/ =~ tmp
              tmp_array = tmp.split(' and ')
              names = [ $1, $2, $3, $4 ]

              res = Scrape::Wiki::Character.match_character_name(names[1], characters_list)
              unless res.empty?
                characters_list.delete(res)
                res[:en] = Scrape::Wiki::Character.convert_macrons(names[0])
                name_array.push(res)
              end
              res = Scrape::Wiki::Character.match_character_name(names[3], characters_list)
              unless res.empty?
                characters_list.delete(res)
                res[:en] = Scrape::Wiki::Character.convert_macrons(names[2])
                name_array.push(res)
              end

            # Yūri (ユウリ?) / Airi Anri (杏里 あいり Anri Airi?)
            elsif /(.*?) \((.*?)\) \/ (.*?) \((.*?)\)/ =~ tmp
              tmp_array = tmp.split(' / ')
              names = [ $1, $2, $3, $4 ]
              res = self.match_character_name(names[1], characters_list)
              unless res.empty?
                characters_list.delete(res)
                res[:en] = Scrape::Wiki::Character.convert_macrons(names[0])
                name_array.push(res)
              end
              res = Scrape::Wiki::Character.match_character_name(names[3], characters_list)
              unless res.empty?
                characters_list.delete(res)
                res[:en] = Scrape::Wiki::Character.convert_macrons(names[2])
                name_array.push(res)
              end
            else
              # Madoka Kaname (鹿目 まどか Kaname Madoka?)
              puts(tmp)
              if /(.*?) \((.*?)\)/ =~ tmp
                names = [ $1, $2 ]
                res = Scrape::Wiki::Character.match_character_name(names[1], characters_list)
                unless res.empty?
                  characters_list.delete(res)
                  res[:en] = Scrape::Wiki::Character.convert_macrons(names[0])
                  name_array.push(res)
                end
              else
                res = Scrape::Wiki::Character.match_character_name(tmp, characters_list)
                unless res.empty?
                  characters_list.delete(res)
                  res[:en] = Scrape::Wiki::Character.convert_macrons(tmp)
                  name_array.push(res)
                end
              end

            end # if /(.*?) \((.*?)\) and (.*?) \((.*?)\)/ =~ tmp
          end # each
        elsif current.respond_to?(:name) and (current.name == 'h2' or current.name == 'script')
          break
        end

        # next_elementが存在するかどうかの判定
        if current.respond_to?(:next_element)
          current = current.next_element
        else
          break
        end
      end # while true
    end # if

    #puts "ending..."
    #puts "#{name_array}"
    [ name_array, characters_list]
  end



  # 日本語のキャラクタ一覧とマッチするキャラクタかどうか調べる
  # @param [Nokogiri::HTML] キャラクター名またはその説明のパースされたHTML
  # @return [String] 英名(日本語名 発音)の形のキャラクター名
  def self.have_name_ja(tag, characters_list)
    tmp = ''
    characters_list.each do |character_name|
      if /#{character_name[:name]}/ =~ tag.inner_text
        if(tag.name == 'dt')
          tmp = tag.inner_text
        elsif(tag.name == 'li')
          tmp = tag.css('b').first.inner_text
          tmp = tmp + " (#{character_name[:name]} #{tmp})"
        end
        return tmp
      end
    end
    return ''
  end
end
