require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_wiki"
include Scrape::Wiki

describe "Scrape" do
  describe "scrape function" do
    it "calls proper functions" do
      Scrape::Wiki.stub(:get_anime_page).and_return
      Scrape::Wiki::Character.stub(:get_anime_character_page).and_return
      Scrape::Wiki::Character.stub(:get_anime_character_name).and_return
      Scrape::Wiki.stub(:save_to_database).and_return
      expect(Scrape::Wiki).to receive(:get_anime_page).exactly(5).times
      expect(Scrape::Wiki::Character).to receive(:get_anime_character_page).exactly(5).times
      expect(Scrape::Wiki::Character).to receive(:get_anime_character_name).exactly(5).times
      expect(Scrape::Wiki).to receive(:save_to_database).exactly(5).times

      Scrape::Wiki.scrape
    end
  end

  describe "get_anime_page function" do
    it "returns a hash" do
      url = 'http://ja.wikipedia.org/wiki/Category:2013%E5%B9%B4%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1'
      result = Scrape::Wiki.get_anime_page(url)

      expect(result).to be_a(Hash)
    end
  end

  describe "get_category_anime_page function" do
    it "returns a String value" do
      anime_title = 'けいおん！'
      category_url = 'http://ja.wikipedia.org/wiki/%E3%81%91%E3%81%84%E3%81%8A%E3%82%93!%E3%81%AE%E7%99%BB%E5%A0%B4%E4%BA%BA%E7%89%A9'

      result = Scrape::Wiki.get_category_anime_page(anime_title, category_url)
      expect(result).to be_a(String)
    end
  end

  describe "get_anime_character_page function" do
    it "returns a hash" do
      url = 'http://ja.wikipedia.org/wiki/%E3%81%91%E3%81%84%E3%81%8A%E3%82%93!%E3%81%AE%E7%99%BB%E5%A0%B4%E4%BA%BA%E7%89%A9'
      hash = { 'けいおん！' => url }

      result_hash = Scrape::Wiki::Character.get_anime_character_page(hash)
      #expect(result_hash).to be_a(Hash)
      expect(result_hash).to be_a(Array)
    end
  end

  describe "get_anime_character_name function" do
    it "returns a Hash value" do
      wiki_url = 'http://ja.wikipedia.org/wiki/%E3%81%91%E3%81%84%E3%81%8A%E3%82%93!%E3%81%AE%E7%99%BB%E5%A0%B4%E4%BA%BA%E7%89%A9'
      hash = { 'けいおん！' => wiki_url }

      puts result = Scrape::Wiki::Character.get_anime_character_name(hash)
      expect(result).to be_a(Hash)
    end
    it "can include an array argument" do
      array = [["けいおん！", "http://ja.wikipedia.org/wiki/%E3%81%91%E3%81%84%E3%81%8A%E3%82%93!%E3%81%AE%E7%99%BB%E5%A0%B4%E4%BA%BA%E7%89%A9"]]

      puts result = Scrape::Wiki::Character.get_anime_character_name(array)
      expect(result).to be_a(Hash)
    end
  end

  describe "save_to_database function" do
    let(:hash) {{
      Prisma_Illya:[
          ['イリヤスフィール・フォン・アインツベルン', 'Illyasviel von Einzbern'],
          ['美遊・エーデルフェルト', 'Miyu Edelfelt'],
        ],
      Madoka: [
        ['鹿目 まどか', 'かなめ まどか'],
        ['美樹 さやか', 'みき さやか']
      ]
    }}

    it "save valid values to database" do
      Scrape::Wiki.save_to_database(hash)

      expect(Person.count).to eq(4)
      expect(Person.first.keywords.count).to eq(2)
      expect(Person.first.titles.count).to eq(1)
      expect(Person.second.titles.count).to eq(1)
      expect(Title.count).to eq(2)
    end
  end
end