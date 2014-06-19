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
  end

  describe "deliver_from_word function" do
    it "deliver properly" do
      FactoryGirl.create(:image)
      FactoryGirl.create(:user_with_target_words, words_count: 5)
      Deliver.should_receive(:limit_images).exactly(1).times
      Deliver.should_receive(:deliver_images).exactly(1).times

      Deliver::Words.deliver_from_word(1, User.first.target_words.first, true)
    end
  end

  describe "contains_word function" do
    it "returns true if the original name matches" do
      # タグに「鹿目まどか」という名前を持つものがあるimageを作成する
      image = FactoryGirl.create(:image_with_tags, tags_count: 5)
      person = FactoryGirl.create(:person_madoka)

      # 鹿目まどか」なるtarget_word
      target_word = TargetWord.find(person.target_word_id)

      contains = Deliver::Words.contains_word(image, target_word)
      expect(contains).to eq(true)
    end
    it "returns true if the name_english matches" do
      image = FactoryGirl.create(:image)
      tag = FactoryGirl.create(:tag_en)
      image.tags << tag
      person = FactoryGirl.create(:person_madoka)
      target_word = TargetWord.find(person.target_word_id)

      contains = Deliver::Words.contains_word(image, target_word)
      expect(contains).to eq(true)
    end

    it "returns false if no matches" do
      # 全く登録タグに関する情報が無いimage
      image = FactoryGirl.create(:image)
      person = FactoryGirl.create(:person_madoka)
      target_word = TargetWord.find(person.target_word_id)

      contains = Deliver::Words.contains_word(image, target_word)
      expect(contains).to eq(false)
    end

    it "returns true if its title or caption contains the keyword" do
      image = FactoryGirl.create(:image_madoka)
      person = FactoryGirl.create(:person_madoka)
      target_word = TargetWord.find(person.target_word_id)

      contains = Deliver::Words.contains_word(image, target_word)
      expect(contains).to eq(true)
    end
  end


  describe "get_images function" do
    before do
      @name = '鹿目まどか1'
    end

    it "get images relation which have tags" do
      FactoryGirl.create(:image_min)                        # tag有
      FactoryGirl.create(:image_with_tags, tags_count: 5)   # tag無

      expect(Deliver::Words.get_images(true, @name).count).to eql(1)
    end
    it "includes images which have nil value in is_illust column with true flag" do
      # Imageを２レコード作成
      FactoryGirl.create(:image_with_tags, tags_count: 5)        # is_illust: true
      FactoryGirl.create(:image_with_only_tags, tags_count: 5)   # is_illust: nil

      expect(Deliver::Words.get_images(true, @name).count).to eql(1)
    end
    it "ignores images which have nil value in is_illust column with false flag" do
      FactoryGirl.create(:image_with_tags, tags_count: 5)        # is_illust: true
      FactoryGirl.create(:image_with_only_tags, tags_count: 5)   # is_illust: nil

      expect(Deliver::Words.get_images(false, @name).count).to eql(1)
    end
  end
end