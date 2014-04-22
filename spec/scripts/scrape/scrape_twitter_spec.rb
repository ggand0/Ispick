require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_twitter"

describe Scrape::Twitter do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    IO.any_instance.stub(:puts)       # コンソールに出力しないようにしておく
    Resque.stub(:enqueue).and_return  # resqueにenqueueしないように
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
      #@tweet = client.status('454783931636670464')
      @tweet = Twitter::Tweet.new({id:1})
    end
    it "returns image_data array" do
      # APIアクセスしないようにstubしている
      Twitter::Tweet.any_instance.stub(:media?).and_return(true)
      Twitter::Tweet.any_instance.stub(:text).and_return('大佐、会議室でよく使うハンドサイン発見しました☆パァ')
      Twitter::Tweet.any_instance.stub(:url).and_return(
        'https://twitter.com/wycejezevix/status/454783931636670464')
      Twitter::Tweet.any_instance.stub(:retweet_count).and_return(0)
      Twitter::Tweet.any_instance.stub(:favorite_count).and_return(0)
      Twitter::Tweet.any_instance.stub(:created_at).and_return(DateTime.now)
      Twitter::Tweet.any_instance.stub(:media).and_return([Twitter::Media::Photo.new({id:1})])
      Twitter::Media::Photo.any_instance.stub(:media_uri).and_return('src_url_of_media.png')
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

  describe "get_tags function" do
    it "returns an array of tags" do
      tags = Scrape::Twitter.get_tags('Madoka')
      expect(tags).to be_an(Array)
      expect(tags.first.name).to eql('Madoka')
    end
    it "uses existing tags if tags are duplicate" do
      image = FactoryGirl.create(:image)
      tag = FactoryGirl.create(:tag)
      image.tags << tag

      tags = Scrape::Twitter.get_tags('鹿目まどか')
      expect(tags.first.images.first.id).to eql(tag.images.first.id)
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
    it "does not call scrape_with_keyword function when targetable is NOT enabled" do
      FactoryGirl.create(:target_word_not_enabled)
      Scrape::Twitter.stub(:scrape_with_keyword).and_return
      Scrape::Twitter.should_not_receive(:scrape_with_keyword)

      Scrape::Twitter.scrape()
    end
    it "skips keywords with nil or empty value" do
      nil_word = TargetWord.new
      nil_word.save!
      Scrape::Twitter.stub(:scrape_with_keyword).and_return
      Scrape::Twitter.should_not_receive(:scrape_with_keyword)

      Scrape::Twitter.scrape()
    end

  end
end