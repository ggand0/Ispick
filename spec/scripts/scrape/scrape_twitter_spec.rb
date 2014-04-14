require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_twitter"

describe Scrape::Twitter do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    # コンソールに出力しないようにしておく
    IO.any_instance.stub(:puts)
    # resqueにenqueueしないように
    Resque.stub(:enqueue).and_return
  end

  describe "scrape_with_keyword function" do
    it "calls proper methods" do
      Scrape::Twitter.should_receive(:get_tweets)
      Scrape::Twitter.should_receive(:save)
      Scrape::Twitter.stub(:save).and_return()

      Scrape::Twitter.scrape_with_keyword('madoka', 5)
    end
    it "rescues exceptions" do
      Scrape::Twitter.stub(:get_tweets).and_raise Twitter::Error::ClientError
      Scrape::Twitter.stub(:save).and_return()

      Scrape::Twitter.scrape_with_keyword('madoka', 5)
    end
    it "rescues TooManyReq exception" do
      Twitter::RateLimit.stub(:reset_in).and_return(300)
      Scrape::Twitter.stub(:get_tweets).once.and_raise Twitter::Error::TooManyRequests
      Scrape::Twitter.stub(:save).and_return()
      Scrape::Twitter.should_receive(:get_tweets)

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
      Twitter::REST::Client
      client = Scrape::Twitter.get_client
      image_data = Scrape::Twitter.get_tweets(client, 'test', 50)

      expect(image_data).to be_an(Array)
    end
  end

  describe "get_contents function" do
    before do
      client = Scrape::Twitter.get_client
      @tweet = client.status('454783931636670464')
    end
    it "returns image_data array" do
      image_data = Scrape::Twitter.get_contents(@tweet)

      expect(image_data).to be_an(Array)
      expect(image_data[0][:page_url]).to eql(
        'https://twitter.com/wycejezevix/status/454783931636670464')
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

  describe "scrape method" do
    it "calls scrape_with_keyword function when targetable is enabled" do
      FactoryGirl.create(:person_madoka)
      Scrape::Twitter.should_receive(:scrape_with_keyword)

      Scrape::Twitter.scrape()
    end
    it "calls scrape_with_keyword function when targetable is NOT enabled" do
      FactoryGirl.create(:target_word_not_enabled)
      Scrape::Twitter.should_not_receive(:scrape_with_keyword)

      Scrape::Twitter.scrape()
    end
  end
end