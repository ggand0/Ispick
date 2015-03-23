#-*- coding: utf-8 -*-
require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_wiki"
include Scrape::Wiki

describe "Scrape" do
  let(:years) { 1 }

  before do
    allow_any_instance_of(IO).to receive(:puts)             # Suppress console outputs
  end

  describe "scrape_all method" do
    it "calls proper methods" do
      allow(Scrape::Wiki).to receive(:get_anime_page).and_return nil
      allow(Scrape::Wiki::Character).to receive(:get_anime_character_page).and_return nil
      allow(Scrape::Wiki::Character).to receive(:get_anime_character_name).and_return nil
      allow(Scrape::Wiki).to receive(:scrape_wiki_for_game_characters).and_return nil
      allow(Scrape::Wiki).to receive(:save_to_database).and_return nil

      expect(Scrape::Wiki).to receive(:get_anime_page).exactly(years).times
      expect(Scrape::Wiki::Character).to receive(:get_anime_character_page).exactly(years).times
      expect(Scrape::Wiki::Character).to receive(:get_anime_character_name).exactly(years).times
      expect(Scrape::Wiki).to receive(:save_to_database).exactly(years).times

      Scrape::Wiki.scrape_all
    end
  end

  describe "get_anime_page method" do
    it "returns a hash" do
      allow(Scrape::Wiki).to receive(:get_english_anime_page).and_return ''

      # Use a fixture that has the same structure as the page
      doc = Nokogiri::HTML(open("#{Rails.root}/spec/fixtures/2011_animes.html"))
      allow(Nokogiri::HTML::Document).to receive(:parse)
      expect(Nokogiri::HTML::Document).to receive(:parse).and_return(doc)

      url = 'http://en.wikipedia.org/wiki/Category:2014_anime_television_series'
      puts result = Scrape::Wiki.get_anime_page(url, true)

      expect(result).to be_a(Hash)
      expect(result.has_key?('魔法少女まどか☆マギカ')).to eq(true)
      expected_value = {:title_ja=>nil, :ja=>nil,
        :en=>"http://en.wikipedia.orghttp://ja.wikipedia.org/wiki/%E9%AD%94%E6%B3%95%E5%B0%91%E5%A5%B3%E3%81%BE%E3%81%A9%E3%81%8B%E2%98%86%E3%83%9E%E3%82%AE%E3%82%AB"}
      expect(result['魔法少女まどか☆マギカ']).to eq(expected_value)
    end
  end

  describe "open_html method" do
    let(:url) { 'http://www.google.co.jp/' }

    it "returns a Nokogiri::HTML object" do
      result = Scrape::Wiki.open_html url
      expect(result).to be_a(Nokogiri::HTML::Document)
    end

    it "returns nil if it has an Errno::ENOENT exception" do
      stub_request(:any, url).to_raise(Errno::ENOENT)

      result = Scrape::Wiki.open_html url
      expect(result).to eql(nil)
    end

    it "returns nil if it has an Errno::ENOENT exception" do
      stub_request(:any, url).to_raise(SocketError)

      result = Scrape::Wiki.open_html url
      expect(result).to eql(nil)
    end
  end

  describe "hash_output method" do
  end

  describe "save_to_database method" do
    let(:hash) {{"Love Live!"=>{:title_en=>"Love Live!", :characters=>[{:name=>"高坂穂乃果", :query=>"高坂穂乃果", :en=>"Honoka Kousaka"}, {:name=>"園田海未", :query=>"園田海未", :en=>"Umi Sonoda"}, {:name=>"南ことり", :query=>"南ことり", :en=>"Kotori Minami"}, {:name=>"矢澤にこ", :query=>"矢澤にこ", :en=>"Nico Yazawa"}, {:name=>"絢瀬絵里", :query=>"絢瀬絵里", :en=>"Eli Ayase"}, {:name=>"東條希", :query=>"東條希", :en=>"Nozomi Tojo"}, {:name=>"西木野真姫", :query=>"西木野真姫", :en=>"Maki Nishikino"}, {:name=>"小泉花陽", :query=>"小泉花陽", :en=>"Hanayo Koizumi"}, {:name=>"星空凛", :query=>"星空凛", :en=>"Rin Hoshizora"}]}, "Love Live!2"=>{:title_en=>"Love Live!2", :characters=>[{:name=>"高坂穂乃果", :query=>"高坂穂乃果", :en=>"Honoka Kousaka"}, {:name=>"園田海未", :query=>"園田海未", :en=>"Umi Sonoda"}, {:name=>"南ことり", :query=>"南ことり", :en=>"Kotori Minami"}, {:name=>"矢澤にこ", :query=>"矢澤にこ", :en=>"Nico Yazawa"}, {:name=>"絢瀬絵里", :query=>"絢瀬絵里", :en=>"Eli Ayase"}, {:name=>"東條希", :query=>"東條希", :en=>"Nozomi Tojo"}, {:name=>"西木野真姫", :query=>"西木野真姫", :en=>"Maki Nishikino"}, {:name=>"小泉花陽", :query=>"小泉花陽", :en=>"Hanayo Koizumi"}, {:name=>"星空凛", :query=>"星空凛", :en=>"Rin Hoshizora"}]}}}

    it "save valid values to database" do
      Scrape::Wiki.save_to_database(hash)
      puts "foobar   :   #{Person.first.keywords.inspect}"
      expect(Person.count).to eq(9)
      expect(Person.first.keywords.count).to eq(1)
      expect(Person.first.titles.count).to eq(1)
      expect(Person.last.titles.count).to eq(1)
      expect(Title.count).to eq(1)              # Because both of english and japanese name is saved into a record
    end
  end

  describe "get_keyword method" do
    it "returns a valid keyword object" do
    end
  end

  describe "get_title method" do
    it "returns a valid title object" do
    end
  end
end
