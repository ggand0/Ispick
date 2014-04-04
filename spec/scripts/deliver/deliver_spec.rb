require 'spec_helper'
require "#{Rails.root}/script/deliver/deliver"
require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

describe "Deliver" do
  before do
    IO.any_instance.stub(:puts)
  end

  describe "delete_excessed_records" do
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

  describe "create_delivered_image function" do
    it "sets all image attributes necessary to new delivered_image" do
      image = FactoryGirl.create(:image)
      delivered_image = Deliver.create_delivered_image(image)

      expect(delivered_image.title).to eq(image.title)
      expect(delivered_image.caption).to eq(image.caption)
      expect(delivered_image.src_url).to eq(image.src_url)
      expect(delivered_image.page_url).to eq(image.page_url)
      expect(delivered_image.posted_at).to eq(image.posted_time)
      expect(delivered_image.site_name).to eq(image.site_name)
      expect(delivered_image.views).to eq(image.view_nums)
      expect(delivered_image.is_illust).to eq(image.is_illust)
    end
  end

  describe "limit_images function" do
    it "rejects an image when it already exists" do
      images = [ FactoryGirl.create(:image) ]
      user = FactoryGirl.create(:user_with_delivered_images_nofile, images_count: 1)
      count = images.count

      images = Deliver.limit_images(user, images)
      expect(images.count).to eq(0)
    end

    it "limits images when its count excess max num" do
      stub_const('Deliver::MAX_DELIVER_NUM', 1)
      images = FactoryGirl.create_list(:image, 3)
      user = FactoryGirl.create(:user_with_delivered_images_nofile, images_count: 1)

      images = Deliver.limit_images(user, images)
      expect(images.count).to eq(1)
    end

    it "does nothing else" do

    end
  end

  describe "deliver_images function" do
    it "adds images to user.delivered_images" do
      target_word = FactoryGirl.create(:target_word)  # 仮にtarget_wordとする
      images = FactoryGirl.create_list(:image, 3)
      user = FactoryGirl.create(:twitter_user)

      Deliver.deliver_images(user, images, target_word)
      expect(user.delivered_images.count).to eq(images.count)
    end
  end

  describe "deliver_from_word function" do
    it "deliver properly" do
      FactoryGirl.create(:user_with_target_words, words_count: 5)
      Deliver.deliver_from_word(1, User.first.target_words.first)
    end
  end
end