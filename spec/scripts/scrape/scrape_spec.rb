require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe Scrape do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  let(:logger) { Logger.new('log/scrape_cron.log') }
  before do
    allow_any_instance_of(IO).to receive(:puts)
    allow(Resque).to receive(:enqueue).and_return nil  # resqueにenqueueしないように
  end

  describe "scrape_all method" do
    it "runs all scraping script" do
      FactoryGirl.create(:target_word)
      allow(Scrape).to receive(:scrape_keyword).and_return nil
      expect(Scrape).to receive(:scrape_keyword).exactly(1).times

      Scrape.scrape_all
    end
  end

  describe "is_duplicate method" do
    it "should return true when arg url is duplicate" do
      FactoryGirl.create(:image_min)
      expect(Scrape.is_duplicate('http://lohas.nicoseiga.jp/thumb/3804029i1')).to eq(true)
    end
    it "should return false when arg url is NOT duplicate" do
      FactoryGirl.create(:image_min)
      expect(Scrape.is_duplicate('http://lohas.nicoseiga.jp/thumb/3804020i')).to eq(false)
    end
  end

  describe "get_tag method" do
    it "creates tags properly" do
      tag = Scrape.get_tag('abcd')
      expect(tag.name).to eq('abcd')
      expect(tag.language).to eq('english')

      tag = Scrape.get_tag('NARUTO')
      expect(tag.name).to eq('NARUTO')
      expect(tag.language).to eq('english')

      tag = Scrape.get_tag('鹿目まどか')
      expect(tag.name).to eq('鹿目まどか')
      expect(tag.language).to eq('japanese')

      tag = Scrape.get_tag('NARUTO100users入り')
      expect(tag.name).to eq('NARUTO100users入り')
      expect(tag.language).to eq('japanese')
    end
  end

  describe "get_tags method" do
    it "create valid tags" do
      tags = ['abcd', '鹿目まどか']
      result = Scrape.get_tags(tags)
      expect(result.first.name).to eq('abcd')
      expect(result.first.language).to eq('english')
      expect(result[1].name).to eq('鹿目まどか')
      expect(result[1].language).to eq('japanese')
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
      valid_string = 'scraped: 0, duplicates: 0, skipped: 0, avg_time: 0, info: none'
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

  describe "is_ascii method" do
    it "returns valid result" do
      expect(Scrape.is_ascii('abcd')).to eq(true)
      expect(Scrape.is_ascii('NARUTO')).to eq(true)
      expect(Scrape.is_ascii('NARUTO100users入り')).to eq(false)
      expect(Scrape.is_ascii('策士ハナビ')).to eq(false)
      expect(Scrape.is_ascii('👍')).to eq(false)
    end
  end

  describe "remove_nonascii method" do
    it "replaces non-ascii characters to empty strings" do
      string = '№'
      result = Scrape.remove_nonascii(string)
      expect(result).to eq('')
    end

    it "keep other characters" do
      string = 'this is ascii characters1234'
      result = Scrape.remove_nonascii(string)
      expect(result).to eq(string)
    end
  end

end