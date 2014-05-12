require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_wiki"
require "#{Rails.root}/script/scrape/scrape_characters"
include Scrape::Wiki::Character

describe "Scrape::Wiki::Character" do
  describe "get_anime_character_name function" do
    it "returns a valid Hash value" do
      url_ja = 'http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB%E3%81%AE%E3%82%AD%E3%83%A3%E3%83%A9%E3%82%AF%E3%82%BF%E3%83%BC%E4%B8%80%E8%A6%A7'
      url_en = 'http://en.wikipedia.org/wiki/List_of_Puella_Magi_Madoka_Magica_characters'
      wiki_url = { '魔法少女まどか☆マギカ' => { ja: url_ja, en: url_en } }

      puts result = Scrape::Wiki::Character.get_anime_character_name(wiki_url)
      expect(result).to be_a(Hash)
    end
  end

  describe "get_character_name_ja funciton" do
    it "returns a hash that contains valid character names" do
      # 登場人物一覧ページ
      url = 'http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB%E3%81%AE%E3%82%AD%E3%83%A3%E3%83%A9%E3%82%AF%E3%82%BF%E3%83%BC%E4%B8%80%E8%A6%A7'
      html = Scrape::Wiki.open_html url

      result = Scrape::Wiki::Character.get_character_name_ja('魔法少女まどか☆マギカ', html)
      expect(result).to be_an(Array)
      #result.each { |n| puts n.class.name } # => Array
      result.each { |n| puts n }
    end
  end

  describe "get_character_name_en funciton" do
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

      puts result = Scrape::Wiki::Character.get_character_name_en(
        '魔法少女まどか☆マギカ', html, characters_list)
      #result.each { |n| puts "#{n.count}, #{n}" }
      expect(result).to be_a(Hash)
    end
  end

  describe "match_character_name function" do
    it "returns a valid hash" do
      name_string = '(鹿目 まどか, Kaname Madoka)'
      characters_list =[{ name: '鹿目 まどか' }, { name: '美樹 さやか' }]
      puts result = Scrape::Wiki::Character.match_character_name(name_string, characters_list)
      expect(result).to eq({ name: '鹿目 まどか' })
    end
  end


  describe "get_anime_character_page function" do
    it "returns a valid hash" do
      url_ja = 'http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB'
      url_en = 'http://en.wikipedia.org/wiki/Puella_Magi_Madoka_Magica'
      page_hash = { 'まどか' => { ja: url_ja, en: url_en } }

      puts result = Scrape::Wiki::Character.get_anime_character_page(page_hash)
      expect(result).to be_a(Hash)
    end
  end

  describe "get_character_page_ja function" do
    it "returns a valid hash" do
      # 登場人物」の項が概要ページに存在するurl
      url = 'http://ja.wikipedia.org/wiki/%E3%81%93%E3%81%B0%E3%81%A8%E3%80%82'
      #url = 'http://ja.wikipedia.org/wiki/IS_%E3%80%88%E3%82%A4%E3%83%B3%E3%83%95%E3%82%A3%E3%83%8B%E3%83%83%E3%83%88%E3%83%BB%E3%82%B9%E3%83%88%E3%83%A9%E3%83%88%E3%82%B9%E3%80%89'
      html = Scrape::Wiki.open_html(url)
      puts result = Scrape::Wiki::Character.get_character_page_ja('こばと。', url, html)

      # get_anime_character_pageで拾う仕様なので、ここではempty hashを返す
      expect(result).to eql({ title: 'こばと。',
        url: 'http://ja.wikipedia.org/wiki/%E3%81%93%E3%81%B0%E3%81%A8%E3%80%82' })
    end
    it "returns a valid hash with external links" do
      # 登場人物」の項が概要ページに存在するurl
      url = 'http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB'
      html = Scrape::Wiki.open_html(url)
      puts result = Scrape::Wiki::Character.get_character_page_ja('魔法少女まどか☆マギカ', url, html)
      expect(result).to eql({ title: '魔法少女まどか☆マギカ',
        url: 'http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB%E3%81%AE%E3%82%AD%E3%83%A3%E3%83%A9%E3%82%AF%E3%82%BF%E3%83%BC%E4%B8%80%E8%A6%A7' })
    end
  end

  describe "get_character_page_en function" do
    it "returns a valid Hash value" do
      url = 'http://en.wikipedia.org/wiki/Puella_Magi_Madoka_Magica'
      html = Scrape::Wiki.open_html url
      puts result = Scrape::Wiki::Character.get_character_page_en('Puella Magi Madoka Magica', url, html)
      expect(result).to eql({ title: 'Puella Magi Madoka Magica',
        url: 'http://.wikipedia.org/wiki/List_of_Puella_Magi_Madoka_Magica_characters'})

    end
  end
end