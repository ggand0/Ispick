
require "#{Rails.root}/script/scrape/scrape"
require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape_twitter"

describe Scrape::Twitter do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    # コンソールに出力しないようにしておく
    #IO.any_instance.stub(:puts)
  end

  describe "scrape_with_keyword function" do
    it "call proper methods" do
      Scrape::Twitter.hash_tag_search.should_recieve()
      Scrape::Twitter.hash_tag_search.saves()
    end
  end

  describe "get_client function" do
    it "returns twitter client" do
      client = Scrape::Twitter.get_client
      client.class.should eq(Twitter::REST::Client)
    end
  end

  describe "get_tweets function" do
    it "returns tweet array" do
      client = Scrape::Twitter.get_client
      image_data = Scrape::Twitter.get_tweets(client, 'test', 50)
      expect(image_data.count).to be > 0
    end
  end

  describe "get_image_name method" do
    it "returns image name with random value" do
      url = 'test/test.com'
      name = Scrape::Twitter.get_image_name(url)
      expect(name).to match(/twitter/)
    end
  end

  describe "save function" do
    it "save to database properly" do
      image = FactoryGirl.attributes_for(:image_file)
      Scrape::Twitter.save([ image ] )
    end
  end

  describe "hash_tag_search function" do
    it "returns image_data array" do
      client = Scrape::Twitter.get_client
      image_data = Scrape::Twitter.hash_tag_search(client, 'test', 50)
      expect(image_data.count).to be > 0
    end
  end

  describe "scrape method" do
    # 少なくとも20回はget_contentsメソッドを呼び出すこと
    it "should call get_contents method at least 20 time" do
      Scrape::Twitter.scrape_with_keyword.should_recieve()
    end
  end
end