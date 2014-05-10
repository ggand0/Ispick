require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_wiki"
require "#{Rails.root}/script/scrape/scrape_characters"
include Scrape::Wiki::Character

describe "Scrape::Wiki::Character" do
  describe "get_anime_character_page function" do
    it "returns a valid hash" do

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