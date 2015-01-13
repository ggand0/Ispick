#-*- coding: utf-8 -*-
require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_wiki"
require "#{Rails.root}/script/scrape/scrape_characters"
include Scrape::Wiki::Character

describe "Scrape::Wiki::Character" do
  before do
    allow_any_instance_of(IO).to receive(:puts)             # Suppress console outputs
  end

  describe "scrape character pages, then extract character names" do
    it "returns a proper array" do
      anime_page = {
        # PMMM
        "魔法少女まどか☆マギカ"=>{
          :ja=>"http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB",
          :en=>"http://en.wikipedia.org/wiki/Puella_Magi_Madoka_Magica"}
      }
      puts anime_character_page = Scrape::Wiki::Character.get_anime_character_page(anime_page, false)

      # Get character names list
      puts anime_character = Scrape::Wiki::Character.get_anime_character_name(anime_character_page, false)
    end

    it "returns an anime_character_page" do
      anime_page = {
        # Love live!
        "ラブライブ!"=>{:ja=>nil, :en=>"http://en.wikipedia.org/wiki/Love_Live!"}
      }
      puts anime_character_page = Scrape::Wiki::Character.get_anime_character_page(anime_page, false)

      # Get character names list
      puts anime_character = Scrape::Wiki::Character.get_anime_character_name(anime_character_page, false)

    end
  end


  describe "get_anime_character_page method" do
    it "return a valid hash for english" do
      page_hash = {"Love Live!"=>{:ja=>nil, :en=>"http://en.wikipedia.org/wiki/Love_Live!"}}
      valid_hash = {"Love Live!"=>{:ja=>nil, :en=>"http://en.wikipedia.org/wiki/Love_Live!", :title_en=>"Love Live!", :title_ja=>nil}}
      puts result = Scrape::Wiki::Character.get_anime_character_page(page_hash)
      expect(result).to be_a(Hash)
      expect(result).to eq(valid_hash)
    end
  end

  describe "get_character_page_ja method" do
    it "returns the hash that contains characters page url if characters list page exists" do
      # URLs that have a link to "Characters" page
      url = 'http://ja.wikipedia.org/wiki/%E3%81%93%E3%81%B0%E3%81%A8%E3%80%82'
      html = Scrape::Wiki.open_html(url)
      puts result = Scrape::Wiki::Character.get_character_page_ja('こばと。', url, html)

      expect(result).to eql({ title: 'こばと。',
        url: 'http://ja.wikipedia.org/wiki/%E3%81%93%E3%81%B0%E3%81%A8%E3%80%82' })
    end

    it "returns a valid hash with external links" do
      # URLs that have a link to "Characters" page
      url = 'http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB'
      html = Scrape::Wiki.open_html(url)
      puts result = Scrape::Wiki::Character.get_character_page_ja('魔法少女まどか☆マギカ', url, html)
      expect(result).to eql({ title: '魔法少女まどか☆マギカ',
        url: 'http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB%E3%81%AE%E3%82%AD%E3%83%A3%E3%83%A9%E3%82%AF%E3%82%BF%E3%83%BC%E4%B8%80%E8%A6%A7' })
    end
  end

  describe "get_character_page_en method" do
    it "returns a valid Hash value" do
      url = 'http://en.wikipedia.org/wiki/Puella_Magi_Madoka_Magica'
      html = Scrape::Wiki.open_html url

      puts result = Scrape::Wiki::Character.get_character_page_en('Puella Magi Madoka Magica', url, html)
      expect(result).to eql({ title: 'Puella Magi Madoka Magica',
        url: 'http://en.wikipedia.org/wiki/List_of_Puella_Magi_Madoka_Magica_characters'})
    end
  end


  describe "get_anime_character_name method" do
    it "returns a valid Hash value" do
      url_ja = 'http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB%E3%81%AE%E3%82%AD%E3%83%A3%E3%83%A9%E3%82%AF%E3%82%BF%E3%83%BC%E4%B8%80%E8%A6%A7'
      url_en = 'http://en.wikipedia.org/wiki/List_of_Puella_Magi_Madoka_Magica_characters'
      wiki_url = { '魔法少女まどか☆マギカ' => { ja: url_ja, en: url_en } }

      puts result = Scrape::Wiki::Character.get_anime_character_name(wiki_url)
      expect(result).to be_a(Hash)
      puts result['魔法少女まどか☆マギカ']
      expect(result['魔法少女まどか☆マギカ'][:characters].first[:en]).to eq('Madoka Kaname')
    end

    it "returns a valid hash value for english" do
      wiki_url = {"Love Live!"=>{:ja=>nil, :en=>"http://en.wikipedia.org/wiki/Love_Live!", :title_en=>"Love Live!"},
                  "Love Live!2"=>{:ja=>nil, :en=>"http://en.wikipedia.org/wiki/Love_Live!", :title_en=>"Love Live!2"}}

      puts result = Scrape::Wiki::Character.get_anime_character_name(wiki_url)
      expect(result).to be_a(Hash)
      puts result['Love Live!']
      expect(result['Love Live!'][:characters].first[:en]).to eq('Honoka Kousaka')
    end
  end

  describe "get_character_name_ja funciton" do
    it "returns a hash that contains valid character names" do
      # Characters list page
      url = 'http://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB%E3%81%AE%E3%82%AD%E3%83%A3%E3%83%A9%E3%82%AF%E3%82%BF%E3%83%BC%E4%B8%80%E8%A6%A7'
      html = Scrape::Wiki.open_html url

      result = Scrape::Wiki::Character.get_character_name_ja('魔法少女まどか☆マギカ', html)
      expect(result).to be_an(Array)
      result.each { |n| puts n }
    end
  end

  describe "get_character_name_en funciton" do
    it "returns a hash that contains valid character names" do
      # Characters list page
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

      puts result = Scrape::Wiki::Character.get_character_name_en('魔法少女まどか☆マギカ', html)
      expect(result).to be_a(Array)
      expect(result.count).to eq(75)
    end
  end

  describe "match_character_name method" do
    it "returns a valid hash" do
      name_string = '(鹿目 まどか Kaname Madoka)'
      characters_list =[{ name: '鹿目 まどか' }, { name: '美樹 さやか' }]
      puts result = Scrape::Wiki::Character.match_character_name(name_string, characters_list)
      expect(result).to eq({ name: '鹿目 まどか' })
    end

    it "returns a valid hash for livelive" do
      name_string = '高坂 穂乃果 Kōsaka Honoka'
      characters_list =[{ name: '高坂 穂乃果' }, { name: '高坂 穂乃果2' }]
      puts result = Scrape::Wiki::Character.match_character_name(name_string, characters_list)
      expect(result).to eq({ name: '高坂 穂乃果' })
    end
  end

  describe "match_english_name method" do
    it "returns a valid hash" do
      name1 = "高坂 穂乃果"
      name2 = "高坂 穂乃果 Kōsaka Honoka"
      puts result = Scrape::Wiki::Character.match_english_name(name1, name2)
    end
  end

end
