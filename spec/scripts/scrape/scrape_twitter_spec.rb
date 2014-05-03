require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_twitter"

describe Scrape::Twitter do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    IO.any_instance.stub(:puts)       # コンソールに出力しないようにしておく
    Resque.stub(:enqueue).and_return  # resqueにenqueueしないように
  end

  describe "scrape function" do
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
  describe "scrape_keyword function" do
    it "calls scrape_with_keyword function" do
      Scrape::Twitter.should_receive(:scrape_with_keyword).with('madoka', 200, false)
      Scrape::Twitter.scrape_keyword('madoka')
    end
  end

  describe "scrape_with_keyword function" do
    it "calls proper methods" do
      Scrape::Twitter.stub(:get_contents).and_return()
      Scrape::Twitter.should_receive(:get_contents).exactly(1).times

      Scrape::Twitter.scrape_with_keyword('madoka', 5)
    end
    it "rescues exceptions" do
      Scrape::Twitter.stub(:get_contents).and_raise Twitter::Error::ClientError

      Scrape::Twitter.scrape_with_keyword('madoka', 5)
    end
    it "rescues TooManyReq exception" do
      Twitter::RateLimit.stub(:reset_in).and_return(300)
      Scrape::Twitter.stub(:get_contents).once.and_raise Twitter::Error::TooManyRequests
      Scrape::Twitter.should_receive(:get_contents)

      Scrape::Twitter.scrape_with_keyword('madoka', 5)
    end
  end

  describe "get_contents function" do
    it "returns tweet array" do
      client = Scrape::Twitter.get_client

      #Scrape.should_receive(:save_image).exactly(5).times

      #Twitter::REST::Client.any_instance.should_receive(:search).exactly(1).times
      #Scrape::Twitter.should_receive(:get_data)
      Scrape::Twitter.get_contents(client, '鹿目まどか', 200)
    end
  end

  describe "get_data function" do
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
      image_data = Scrape::Twitter.get_data(@tweet)

      expect(image_data).to be_an(Array)
      expect(image_data[0][:page_url]).to eql(
        'https://twitter.com/wycejezevix/status/454783931636670464')
    end
  end

  describe "get_client function" do
    it "returns twitter client" do
      client = Scrape::Twitter.get_client
      expect(client.class).to eq(Twitter::REST::Client)
    end
  end

  describe "get_image_name method" do
    it "returns image name with random value" do
      url = 'test/test.com'
      name = Scrape::Twitter.get_image_name(url)
      expect(name).to match(/twitter/)
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
      page_url = 'https://twitter.com/ogipote/status/419125060968804352'
      client = Scrape::Twitter.get_client
      result = Scrape::Twitter.get_stats(client, page_url)
      expect(result).to be_a(Hash)
      expect(result[:views]).to be_a(Integer)
      expect(result[:favorites]).to be_a(Integer)
    end
  end

end