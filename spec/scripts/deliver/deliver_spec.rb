require 'spec_helper'
require "#{Rails.root}/script/deliver/deliver"
require "#{Rails.root}/script/deliver/deliver_words"
require "#{Rails.root}/script/deliver/deliver_images"
require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

describe "Deliver" do
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return nil  # resqueのjobを実際に実行しないように
    @logger = Logger.new('log/deliver.log')
  end

  describe "deliver function" do
    it "calls proper functions" do
      user = FactoryGirl.create(:user_with_target_words)
      Deliver.stub(:deliver_from_word).and_return nil
      expect(Deliver::Words).to receive(:deliver_from_word).exactly(user.target_words.count).times

      Deliver.deliver(user.id)
    end
  end
  describe "deliver_keyword function" do
    it "calls proper functions" do
      user = FactoryGirl.create(:user_with_target_words)
      target_word = user.target_words.first
      Deliver::Words.stub(:deliver_from_word).and_return nil
      expect(Deliver::Words).to receive(:deliver_from_word).exactly(1).times

      Deliver.deliver_keyword(user.id, target_word.id, @logger)
    end
  end
  describe "deliver_from_word function" do
    it "deliver properly" do
      FactoryGirl.create(:image)
      FactoryGirl.create(:user_with_target_words, words_count: 5)
      Deliver.should_receive(:deliver_images).exactly(1).times

      Deliver::Words.deliver_from_word(1, User.first.target_words.first, @logger)
    end
  end

  describe "delete_excessed_records" do
    it "delete images properly" do
      user = FactoryGirl.create(:user_with_delivered_images_file, images_count: 5)
      images = user.delivered_images
      size = ApplicationHelper.bytes_to_megabytes(images.first.image.data.size)*2 + 1

      # 2レコードのサイズ＋1を指定したので、それを下回らせるために3レコード削除されるはず
      Deliver.delete_excessed_records(images, size)
      expect(User.first.delivered_images.count).to eq(2)
    end
  end


  describe "create_delivered_image function" do
    it "sets all basic image attributes necessary to new delivered_image" do
      delivered_image = Deliver.create_delivered_image(FactoryGirl.create(:image))
      image = delivered_image.image

      expect(image.title).to eq(image.title)
      expect(image.caption).to eq(image.caption)
      expect(image.src_url).to eq(image.src_url)
      expect(image.page_url).to eq(image.page_url)
      expect(image.posted_at).to eq(image.posted_at)
      expect(image.site_name).to eq(image.site_name)
      expect(image.views).to eq(image.views)
      expect(image.is_illust).to eq(image.is_illust)
    end
    it "reference image data" do
      image = FactoryGirl.create(:image)
      delivered_image = Deliver.create_delivered_image(image)
      expect(delivered_image.image).to eql(image)
    end
  end

  describe "limit_images function" do
    it "limits images when its count excess max num" do
      stub_const('Deliver::MAX_DELIVER_NUM', 1)
      images = FactoryGirl.create_list(:image_min, 3)
      user = FactoryGirl.create(:user_with_delivered_images, images_count: 1)

      images = Deliver.limit_images(user, images)
      expect(images.count).to eq(1)
    end
  end

  describe "deliver_images function" do
    it "adds images to user.delivered_images" do
      user = FactoryGirl.create(:twitter_user)
      target_word = FactoryGirl.create(:target_word)  # 仮にtarget_wordとする
      images = [ FactoryGirl.create(:image_file) ]

      Deliver.deliver_images(user, images, target_word)
      expect(user.delivered_images.count).to eq(images.count)
    end

    # DLし終えたものから配信する仕様に改良するまで凍結
=begin
    it "ignores images without paperclip attachment" do
      user = FactoryGirl.create(:twitter_user)
      target_word = FactoryGirl.create(:target_word)
      images = FactoryGirl.create_list(:image, 3)

      # missing画像を全てskipする
      Deliver.deliver_images(user, images, target_word, true)
      expect(user.delivered_images.count).to eq(0)
    end
=end

    # 配信済みの場合target.delivered_imagesに追加されている事
    it "adds to target.delivered_images when it has already delivered" do
      user = FactoryGirl.create(:user_with_delivered_images, images_count: 1)
      target_word = TargetWord.first
      images = [ FactoryGirl.create(:image_for_delivered_image) ]

      images = Deliver.deliver_images(user, images, target_word)
      expect(target_word.delivered_images.count).to eq(1)
    end
  end


  describe "update function" do
    before do
      Scrape::Twitter.stub(:get_stats).and_return({ views: 100, favorites: 100})
      Scrape::Tumblr.stub(:get_stats).and_return({ views: 100, favorites: 100})
      Scrape::Nico.stub(:get_stats).and_return({ views: 100, favorites: 100})
    end

    it "call get_stats functions in proper module" do
      require "#{Rails.root}/script/scrape/scrape"
      require "#{Rails.root}/script/scrape/scrape_twitter"
      require "#{Rails.root}/script/scrape/scrape_tumblr"
      require "#{Rails.root}/script/scrape/scrape_nico"

      user = FactoryGirl.create(:user_with_delivered_images_file, images_count: 5)
      user.delivered_images.each { |d| puts d.image.page_url }

      Scrape::Twitter.should_receive(:get_stats)
      Scrape::Tumblr.should_receive(:get_stats)
      Scrape::Nico.should_receive(:get_stats)

      Deliver.update()
    end
    it "ignores empty relation in user.delivered_images" do
      user = FactoryGirl.create(:user_with_delivered_images_file, images_count: 5)
      user.delivered_images << DeliveredImage.none  # 空のrelationを追加

      Deliver.update
    end
    # 当日配信された画像のみ更新する
    it "updates delivered_image which is delivered in the day" do
      user = FactoryGirl.create(:twitter_user)
      delivered_image = FactoryGirl.create(:delivered_image_no_association)
      delivered_image.created_at = Time.now + 1.day
      user.delivered_images << delivered_image

      Object.const_get(delivered_image.image.module_name).should_receive(:get_stats).exactly(1).times

      Deliver.update()
    end
    it "ignore delivered_image which is delivered in the other days" do
      user = FactoryGirl.create(:twitter_user)
      delivered_image = FactoryGirl.create(:delivered_image_no_association)
      delivered_image.created_at = Time.now - 1.day
      user.delivered_images << delivered_image

      Scrape::Twitter.should_not_receive(:get_stats)
      Scrape::Tumblr.should_not_receive(:get_stats)
      Scrape::Nico.should_not_receive(:get_stats)

      Deliver.update
    end
  end
end