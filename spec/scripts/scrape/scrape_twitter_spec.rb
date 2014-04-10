require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_twitter"

describe Scrape::Twitter do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    # コンソールに出力しないようにしておく
    #IO.any_instance.stub(:puts)
  end

  describe "scrape_with_keyword function" do
    it "call proper methods" do
      Scrape::Twitter.should_receive(:get_tweets)
      Scrape::Twitter.should_receive(:save)
      Scrape::Twitter.stub(:save).and_return()

      Scrape::Twitter.scrape_with_keyword('madoka', 5)
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
      expect(image_data).to be_an(Array)
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
      puts image
      Scrape::Twitter.save([ image ], 'madoka')
    end
  end

  describe "get_stats function" do
    it "returns stats information from a page_url" do
      url = 'https://twitter.com/ogipote/status/419125060968804352'
      result = Scrape::Twitter.get_stats(url)
      expect(result).to be_a(Hash)
    end
  end

  describe "hash_tag_search function" do
    it "returns image_data array" do
      client = Scrape::Twitter.get_client
      image_data = Scrape::Twitter.hash_tag_search(client, 'test', 50)
      expect(image_data).to be_an(Array)
    end
  end

  describe "scrape method" do
    it "should call scrape_with_keyword function" do
      FactoryGirl.create(:person_madoka)
      Scrape::Twitter.should_receive(:scrape_with_keyword)
      Scrape::Twitter.scrape()
    end
  end
end