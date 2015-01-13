#-*- coding: utf-8 -*-
require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_wiki"
require "#{Rails.root}/script/scrape/scrape_game_characters"
include Scrape::Wiki::GameCharacter

describe "Scrape::Wiki::GameCharacter" do
  before do
    allow_any_instance_of(IO).to receive(:puts)
  end

  describe "get_game_character_name function" do
    it "returns a valid Hash value" do
      url_ja = 'http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB%E3%81%AE%E3%82%AD%E3%83%A3%E3%83%A9%E3%82%AF%E3%82%BF%E3%83%BC%E4%B8%80%E8%A6%A7'
      url_en = 'http://en.wikipedia.org/wiki/List_of_Puella_Magi_Madoka_Magica_characters'
      wiki_url = { '魔法少女まどか☆マギカ' => { ja: url_ja, en: url_en } }

      puts result = Scrape::Wiki::GameCharacter.get_game_character_name(wiki_url)
      expect(result).to be_a(Hash)
      puts result['魔法少女まどか☆マギカ']
      #expect(result['魔法少女まどか☆マギカ'][:characters].first[:en]).to eq('Madoka Kaname')
      expect(result['魔法少女まどか☆マギカ'][:characters].first[:name]).to eq('鹿目 まどか')
    end
  end

  describe "get_game_character_name_ja funciton" do
    it "returns a hash that contains valid character names" do
      # 登場人物一覧ページ
      url = 'http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB%E3%81%AE%E3%82%AD%E3%83%A3%E3%83%A9%E3%82%AF%E3%82%BF%E3%83%BC%E4%B8%80%E8%A6%A7'
      html = Scrape::Wiki.open_html url

      result = Scrape::Wiki::GameCharacter.get_game_character_name_ja('魔法少女まどか☆マギカ', html)
      expect(result).to be_an(Array)
      #result.each { |n| puts n.class.name } # => Array
      result.each { |n| puts n }
    end
  end

  describe "get_game_character_name_en funciton" do
    it "returns a hash that contains valid character names" do
      # 登場人物一覧ページ
      url = 'http://en.wikipedia.org/wiki/List_of_Puella_Magi_Madoka_Magica_characters'
      html = Scrape::Wiki.open_html url
      characters_list = [
        {:name=>"鹿目 まどか", :query=>"鹿目まどか", :_alias=>"かなめ まどか"},
        {:name=>"暁美 ほむら", :query=>"暁美ほむら", :_alias=>"あけみ ほむら"},
        {:name=>"美樹 さやか", :query=>"美樹さやか", :_alias=>"みき さやか"},
        {:name=>"巴 マミ", :query=>"巴マミ", :_alias=>"ともえ マミ"},
        {:name=>"佐倉 杏子", :query=>"佐倉杏子", :_alias=>"さくら きょうこ"},
        {:name=>"キュゥべえ", :query=>"キュゥべえ", :_alias=>""}
      ]

      puts result = Scrape::Wiki::GameCharacter.get_game_character_name_en(
        '魔法少女まどか☆マギカ', html, characters_list)
      #result.each { |n| puts "#{n.count}, #{n}" }
      expect(result).to be_a(Array)
      expect(result.count).to eq(6)
    end
  end

end
