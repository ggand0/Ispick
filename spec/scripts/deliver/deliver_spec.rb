require 'spec_helper'
require "#{Rails.root}/script/deliver/deliver"
require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

describe "Deliver" do
  describe "delete_excessed_records" do
    before do
      #IO.any_instance.stub(:puts)
    end
    it "delete images properly" do
      FactoryGirl.create(:user_with_delivered_images, images_count: 5)
      images = User.first.delivered_images
      size = ApplicationHelper.bytes_to_megabytes(images.first.data.size)*2 + 1
      Deliver.delete_excessed_records(User.first.delivered_images, size)

      expect(User.first.delivered_images.count).to eq(2)
      User.first.delivered_images.each do |d|
        puts d.created_at
      end
    end
  end

  describe "contains_word function" do
    it "returns true if some column matches" do
      # タグに「鹿目まどか」という名前を持つものがあるimageを作成する
      image = FactoryGirl.create(:image_with_tags, tags_count: 5)
      person = FactoryGirl.create(:person_madoka)
      target_word = TargetWord.find(person.target_word_id)
      # 鹿目まどか」なるtarget_word

      contains = Deliver.contains_word(image, target_word)
      expect(contains).to eq(true)
    end

    it "returns false if no matches" do
      # 全く登録タグに関する情報が無いimage
      image = FactoryGirl.create(:image)
      person = FactoryGirl.create(:person_madoka)
      target_word = TargetWord.find(person.target_word_id)

      contains = Deliver.contains_word(image, target_word)
      expect(contains).to eq(false)
    end
  end

  describe "limit_images function" do

  end

  describe "deliver_images function" do

  end

  describe "deliver_from_word function" do
    it "deliver properly" do
      FactoryGirl.create(:user_with_target_words, words_count: 5)
      Deliver.deliver_from_word(1, User.first.target_words.first)
    end
  end
end