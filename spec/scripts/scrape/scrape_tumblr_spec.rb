require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_tumblr"

describe Scrape::Tumblr do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    # コンソールに出力しないようにしておく
    IO.any_instance.stub(:puts)
  end

  describe "get_stats function" do
    it "returns a hash with favorites value" do
      page_url = 'http://zan66.tumblr.com/post/74921850483'
      stats = Scrape::Tumblr.get_stats(page_url)
      expect(stats).to be_a(Hash)
    end
  end

  describe "get_client function" do
    it "returns tumblr client" do
      client = Scrape::Tumblr.get_client
      client.class.should eq(Tumblr::Client)
    end
  end


  describe "scrape method" do
    it "should call scrape_with_keyword function" do
      FactoryGirl.create(:person_madoka)
      Scrape::Tumblr.should_receive(:scrape_with_keyword)
      Scrape::Tumblr.scrape()
    end
  end
end