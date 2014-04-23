require 'spec_helper'
require "#{Rails.root}/script/deliver/deliver"
require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

describe "Deliver" do
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return  # resqueのjobを実際に実行しないように
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
    it "sets all basic image attributes necessary to new delivered_image" do
      image = FactoryGirl.create(:image)
      delivered_image = Deliver.create_delivered_image(image, false)

      expect(delivered_image.title).to eq(image.title)
      expect(delivered_image.caption).to eq(image.caption)
      expect(delivered_image.src_url).to eq(image.src_url)
      expect(delivered_image.page_url).to eq(image.page_url)
      expect(delivered_image.posted_at).to eq(image.posted_at)
      expect(delivered_image.site_name).to eq(image.site_name)
      expect(delivered_image.views).to eq(image.views)
      expect(delivered_image.is_illust).to eq(image.is_illust)
    end
    it "copies paperclip attachment if the copy arg is true" do
      image = FactoryGirl.create(:image)
      delivered_image = Deliver.create_delivered_image(image, true)
      expect(delivered_image.data).not_to eql(nil)
    end
    it "skips copying image attchment if the copy arg is false" do
      image = FactoryGirl.create(:image)
      delivered_image = Deliver.create_delivered_image(image, false)

      # コピーされていない（デフォルトのmissing画像が割り当てられたままである）こと
      expect(delivered_image.data.url).to eql(Deliver::MISSING_URL)
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
      user = FactoryGirl.create(:twitter_user)
      target_word = FactoryGirl.create(:target_word)  # 仮にtarget_wordとする
      #images = FactoryGirl.create_list(:image, 3)
      images = [ FactoryGirl.create(:image_file) ]

      Deliver.deliver_images(user, images, target_word, true)
      expect(user.delivered_images.count).to eq(images.count)
    end
    it "ignores images without paperclip attachment" do
      user = FactoryGirl.create(:twitter_user)
      target_word = FactoryGirl.create(:target_word)
      images = FactoryGirl.create_list(:image, 3)

      # missing画像は全てskipされるはずである
      Deliver.deliver_images(user, images, target_word, true)
      expect(user.delivered_images.count).to eq(0)
    end
    it "enqueues a resque job if copy arg is false" do
      user = FactoryGirl.create(:twitter_user)
      target_word = FactoryGirl.create(:target_word)
      images = FactoryGirl.create_list(:image, 3)

      # copyしない時（タグ登録直後の配信である時）はResqueにqueueを追加すること
      Resque.should_receive(:enqueue).exactly(3).times
      Deliver.deliver_images(user, images, target_word, false)
    end
  end

  describe "deliver_from_word function" do
    it "deliver properly" do
      FactoryGirl.create(:image)
      FactoryGirl.create(:user_with_target_words, words_count: 5)
      Deliver.should_receive(:limit_images).exactly(1).times
      Deliver.should_receive(:deliver_images).exactly(1).times
      #Deliver.should_receive(:contains_word).at_least(1).times

      Deliver.deliver_from_word(1, User.first.target_words.first, true)
    end
  end

  describe "get_images function" do
    it "get images relation which have tags" do
      FactoryGirl.create(:image_min)                        # tag有
      FactoryGirl.create(:image_with_tags, tags_count: 5)   # tag無

      expect(Deliver.get_images(true).count).to eql(1)
    end
    it "ignores images which have nil value in is_illust column with true flag" do
      FactoryGirl.create(:image_with_tags, tags_count: 5)        # is_illust: true
      FactoryGirl.create(:image_with_only_tags, tags_count: 5)   # is_illust: nil

      expect(Deliver.get_images(true).count).to eql(1)
    end
    it "includes images which have nil value in is_illust column with false flag" do
      FactoryGirl.create(:image_with_tags, tags_count: 5)        # is_illust: true
      FactoryGirl.create(:image_with_only_tags, tags_count: 5)   # is_illust: nil

      expect(Deliver.get_images(false).count).to eql(2)
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

      user = FactoryGirl.create(:user_with_delivered_images_nofile, images_count: 5)
      user.delivered_images.each { |d| puts d.page_url }

      Scrape::Twitter.should_receive(:get_stats)
      Scrape::Tumblr.should_receive(:get_stats)
      Scrape::Nico.should_receive(:get_stats)

      Deliver.update()
    end
    it "ignores empty relation in user.delivered_images" do
      user = FactoryGirl.create(:user_with_delivered_images_nofile, images_count: 5)
      user.delivered_images << DeliveredImage.none  # 空のrelationを追加

      Deliver.update()
    end
    it "updates delivered_image which is delivered in the day" do
      user = FactoryGirl.create(:twitter_user)
      delivered_image = FactoryGirl.create(:delivered_image_no_association)
      delivered_image.created_at = Time.now + 1.day
      user.delivered_images << delivered_image

      Object.const_get(delivered_image.module_name).should_receive(:get_stats).exactly(1).times

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

      Deliver.update()
    end
  end
end