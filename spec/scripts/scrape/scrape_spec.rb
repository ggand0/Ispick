require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe Scrape do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  let(:logger) { Logger.new('log/scrape_cron.log') }
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return nil  # resqueにenqueueしないように
  end

  describe "scrape_all method" do
    it "runs all scraping script" do
      FactoryGirl.create(:target_word)
      Scrape.stub(:scrape_keyword).and_return nil
      Scrape.should_receive(:scrape_keyword).exactly(1).times

      Scrape.scrape_all
    end
  end

  describe "is_duplicate method" do
    it "should return true when arg url is duplicate" do
      FactoryGirl.create(:image_min)
      Scrape.is_duplicate('http://lohas.nicoseiga.jp/thumb/3804029i1').should eq(true)
    end
    it "should return false when arg url is NOT duplicate" do
      FactoryGirl.create(:image_min)
      Scrape.is_duplicate('http://lohas.nicoseiga.jp/thumb/3804020i').should eq(false)
    end
  end

  describe "get_query function" do
    it "returns proper string when target_word has a person model" do
      target_word = FactoryGirl.create(:word_with_person)
      result = Scrape.get_query target_word

      expect(result).to eq('鹿目まどか')
    end

    it "returns proper string when target_word doesn't have a person model" do
      target_word = FactoryGirl.create(:target_word)
      result = Scrape.get_query target_word

      expect(result).to eq('鹿目 まどか（かなめ まどか）1')
    end
  end

  describe "get_query_en function" do
    it "returns proper string" do
      target_word = TargetWord.create(word: 'Madoka Kaname')
      result = Scrape.get_query_en target_word, true

      expect(result).to eq('Madoka Kaname')
    end
  end



end