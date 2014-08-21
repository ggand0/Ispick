require 'spec_helper'
require "#{Rails.root}/script/deliver/deliver"
require "#{Rails.root}/script/deliver/deliver_words"
require "#{Rails.root}/script/deliver/deliver_images"
require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

describe "Deliver::Words" do
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return nil  # resqueのjobを実際に実行しないように

    @image = FactoryGirl.create(:image_with_specific_tags)   # '鹿目まどか'タグを持つImage
    @target_word = FactoryGirl.create(:word_with_person)
    @logger = Logger.new('log/deliver.log')
  end

  describe "deliver_from_word function" do
    it "deliver properly" do
      FactoryGirl.create(:user_with_target_words, words_count: 5)
      expect(Deliver).to receive(:deliver_images).exactly(1).times

      Deliver::Words.deliver_from_word(1, User.first.target_words.first, @logger)
    end
  end

  describe "contains_word function" do
    # タグ文字列と完全一致すればtrue
    it "returns true if the original name matches" do
      contains = Deliver::Words.contains_word(@image, @target_word)
      expect(contains).to eq(true)
    end
    # 英名でヒットすればtrue
    it "returns true if the name_english matches" do
      contains = Deliver::Words.contains_word(@image, @target_word)
      expect(contains).to eq(true)
    end
    # 全く登録タグに関する情報が無いimageに対してはfalse
    it "returns false if no matches" do
      image = FactoryGirl.create(:image_min)
      contains = Deliver::Words.contains_word(image, @target_word)
      expect(contains).to eq(false)
    end
    # titleかcaptionに一致すればtrue
    it "returns true if its title or caption contains the keyword" do
      image = FactoryGirl.create(:image_madoka)

      contains = Deliver::Words.contains_word(image, @target_word)
      expect(contains).to eq(true)
    end
    # 関連語がタグか文字情報にマッチすればtrue
    it "returns true if image's tag or string info contains the related words" do
      target_word = FactoryGirl.create(:target_word_title)
      contains = Deliver::Words.contains_word(@image, target_word)
      expect(contains).to eq(true)
    end
  end

  describe "get_query_ja function" do
    it "returns valid query" do
      expect(Deliver::Words.get_query_ja(@target_word)).to eq('鹿目まどか')
    end
  end
  describe "get_query_en function" do
    it "returns valid query" do
      expect(Deliver::Words.get_query_en(@target_word)).to eq('Madoka Kaname')
    end
  end
  describe "get_query_keywords function" do
    it "returns valid array" do
      result = Deliver::Words.get_query_keywords(@target_word)
      #expect(result).to be_an(ActiveRecord::Associations::CollectionProxy)
      expect(result).to be_an(Array)
      expect(result).to eq(['魔法少女まどか☆マギカ', 'かなめ まどか'])
    end
  end
  describe "match_word function" do
    # contains_wordと同様
    it "returns true if target word exists in tags" do
      expect(Deliver::Words.match_word(@image, '鹿目まどか')).to eq(true)
    end
    it "returns true if target word is contained in image's title" do
      image = FactoryGirl.create(:image_madoka)
      expect(Deliver::Words.match_word(image, '鹿目まどか')).to eq(true)
    end
    it "returns false otherwise" do
      image = FactoryGirl.create(:image_min)
      expect(Deliver::Words.match_word(image, '鹿目まどか')).to eq(false)
    end
  end

=begin
  describe "get_images function" do
    it "get images relation which have tags" do
      FactoryGirl.create(:image_min)                        # tag無
      # @image => tag有
      expect(Deliver::Words.get_images(@target_word, @logger).count).to eql(1)
    end

    it "includes images which have nil value in is_illust column with true flag" do
      # Imageを２レコード作成
      # @image => is_illust: true
      FactoryGirl.create(:image_with_only_tags, tags_count: 5)   # is_illust: nil

      expect(Deliver::Words.get_images(@target_word, @logger).count).to eql(1)
    end
  end
=end
end