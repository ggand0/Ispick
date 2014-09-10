#-*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'natto'


# Scrape anime characters names from Wikipedia
# wikipediaからアニメのキャラクター名を抽出する
module Scrape::Wiki::Game
  require "#{Rails.root}/script/scrape/scrape_characters"
  require "#{Rails.root}/script/scrape/scrape_game_characters"
  include Character
  include GameCharacter

  def self.scrape_wiki_for_game_characters

    # アニメの概要ページのURL/タイトルのHashを取得
    game_page = self.get_game_page

    # 登場人物の一覧ページの配列を取得、
    # 一覧ページが無い場合は概要ページを配列に追加
    game_character_page = Scrape::Wiki::Character.get_anime_character_page(game_page)

    # 有名タイトルを手動で追加
    #game_character_page = self.get_spc_game_character_page(game_character_page)

    # キャラクタ名の一覧配列を取得
    game_character = Scrape::Wiki::GameCharacter.get_game_character_name(game_character_page)

    # キャラクタ名をDBヘ保存
    #self.hash_output(anime_character)
    self.save_to_database(game_character)
  end

  # ミリオンセラーのゲーム概要ページを取得
  # @return [hash] ゲームページのURLのハッシュ
  def self.get_game_page
    url = 'http://ja.wikipedia.org/wiki/%E3%83%9F%E3%83%AA%E3%82%AA%E3%83%B3%E3%82%BB%E3%83%A9%E3%83%BC%E3%81%AE%E3%82%B2%E3%83%BC%E3%83%A0%E3%82%BD%E3%83%95%E3%83%88%E4%B8%80%E8%A6%A7'

    html = self.open_html(url)
    game_page = {}

    html.css("table[class='sortable wikitable']").first.css('tr').each do |item|
      if !item.css('td').first.nil?
        page_url_ja = "http://ja.wikipedia.org#{item.css("td > a").first.attr('href')}"
        page_url_en = self.get_anime_page_en(page_url_ja)
        if page_url_en != 'no_characters'
          title = item.css('td > a').first.attr('title')
          puts(title)
          game_page[title] = { ja: page_url_ja, en: page_url_en }
        end
      end
    end
    return game_page
  end

  # キャラクターを持つゲームか判定
  # @param [html] Nokogiriでパースされたhtml
  # @return [boolean] 登場人物を持てばtrue
  def self.detect_having_characters(html)
    html.css("span[class='mw-headline']").each do |item|
      if /(主な|主要|登場)*(人物|キャラクター)(一覧)*/ =~ item.content
        return true
      end
    end

    return false
  end
end