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

      expect(result).to eq('鹿目まどか1')
    end

    it "returns proper string when target_word doesn't have a person model" do
      target_word = FactoryGirl.create(:target_word)
      result = Scrape.get_query target_word

      expect(result).to eq('鹿目まどか1')
    end
  end

  describe "get_query_en function" do
    it "returns proper string" do
      target_word = TargetWord.create(name: 'Madoka Kaname')
      result = Scrape.get_query_en target_word, true

      expect(result).to eq('Madoka Kaname')
    end
  end

  describe "get_result_hash method" do
    it "returns the empty hash including proper keys" do
      result = Scrape.get_result_hash
      expect(result).to be_a(Hash)
      expect(result).to have_key(:scraped)
      expect(result).to have_key(:duplicates)
      expect(result).to have_key(:skipped)
      expect(result).to have_key(:avg_time)
    end
  end

  describe "get_result_string method" do
    it "return the valid string based on a result hash" do
      result = Scrape.get_result_hash
      string = Scrape.get_result_string(result)
      valid_string = 'scraped: 0, duplicates: 0, skipped: 0, avg_time: 0, info: '
      expect(string).to eq(valid_string)
    end
  end

  describe "get_option_hash method" do
    it "returns a valid option hash" do
      result = Scrape.get_option_hash(true, true, true, true)
      expect(result).to be_a(Hash)
      expect(result).to have_key(:validation)
      expect(result).to have_key(:large)
      expect(result).to have_key(:verbose)
      expect(result).to have_key(:resque)
    end
  end

  describe "remove_4bytes method" do
    it "returns a string which 4byte strings are removed" do
      string = '👍'
      result = Scrape.remove_4bytes(string)
      expect(result).to eq('')
    end
  end

end