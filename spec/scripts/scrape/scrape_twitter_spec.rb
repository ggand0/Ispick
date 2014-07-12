require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_twitter"

describe Scrape::Twitter do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    IO.any_instance.stub(:puts)           # コンソールに出力しないようにしておく
    Resque.stub(:enqueue).and_return nil  # resqueにenqueueしないように

    @client = Scrape::Twitter.new(nil, 10)
    @twitter_client = Scrape::Twitter.get_client
  end

  describe "scrape function" do
    it "calls scrape_using_api function when targetable is enabled" do
      FactoryGirl.create(:person_madoka)
      @client.stub(:scrape_target_words).and_return nil
      expect(@client).to receive(:scrape_target_words)

      @client.scrape(60)
    end
  end

  describe "scrape_target_word function" do
    let(:function_response) { { scraped: 0, duplicates: 0, skipped: 0, avg_time: 0 } }

    it "calls scrape_using_api function" do
      target_word = FactoryGirl.create(:word_with_person)
      @client.should_receive(:scrape_using_api)
      @client.stub(:scrape_using_api).and_return(function_response)

      @client.scrape_target_word(1, target_word)
    end
  end

  describe "scrape_using_api function" do
    before do
      @target_word = FactoryGirl.create(:word_with_person)
    end

    it "calls proper methods" do
      Scrape::Twitter.stub(:get_contents).and_return nil
      Scrape::Twitter.any_instance.should_receive(:get_contents).exactly(1).times

      @client.scrape_using_api(@target_word)
    end

    it "rescues exceptions" do
      Scrape::Twitter.stub(:get_contents).and_raise Twitter::Error::ClientError

      @client.scrape_using_api(@target_word)
    end

    it "rescues TooManyRequest exception" do
      Twitter::RateLimit.any_instance.stub(:reset_in).and_return(300)
      #Scrape::Twitter.any_instance.stub(:get_contents) {
      @client.stub(:get_contents) {
        #Scrape::Twitter.unstub(:get_contents); raise Twitter::Error::TooManyRequests
        @client.unstub(:get_contents); raise Twitter::Error::TooManyRequests
      }

      #Scrape::Twitter.any_instance.should_receive(:get_contents).exactly(2).times
      @client.should_receive(:get_contents).exactly(2).times
      Scrape::Twitter.any_instance.should_receive(:sleep).with(300)

      @client.scrape_using_api(@target_word)
    end
  end

  describe "get_contents function" do
    it "returns scarping result hash" do
      target_word = FactoryGirl.create(:word_with_person)
      query = Scrape.get_query(target_word)
      result = @twitter_client.search("#{query} -rt", locale: 'ja', result_type: 'recent', include_entity: true)
      Twitter::REST::Client.any_instance.stub(:search).and_return(result)
      Twitter::REST::Client.any_instance.should_receive(:search)

      result_hash = @client.get_contents(target_word)
      expect(result_hash).to be_a(Hash)
    end
    it "call save_image function with right arguments" do
      # TODO: 画像tweetを含むTwitter API responseをTwitter::SearchResultsオブジェクトにパースし、
      # Scrape.save_imageが画像ツイート数と同じ回数呼ばれている事をassertする
    end
  end

  describe "get_data function" do
    before do
      client = Scrape::Twitter.get_client
      #@tweet = client.status('454783931636670464')
      @tweet = Twitter::Tweet.new({id:1})
    end
    it "returns image_data array" do
      # 仮のデータをstubを利用してreturnする
      # FactoryGirlを使用して書き換えても良い
      Twitter::Tweet.any_instance.stub(:media?).and_return(true)
      Twitter::Tweet.any_instance.stub(:text).and_return(
        '大佐、会議室でよく使うハンドサイン発見しました☆パァ'
      )
      Twitter::Tweet.any_instance.stub(:url).and_return(
        'https://twitter.com/wycejezevix/status/454783931636670464'
      )
      Twitter::Tweet.any_instance.stub(:retweet_count).and_return(0)
      Twitter::Tweet.any_instance.stub(:favorite_count).and_return(0)
      Twitter::Tweet.any_instance.stub(:created_at).and_return(DateTime.now)
      Twitter::Tweet.any_instance.stub(:media).and_return([Twitter::Media::Photo.new({id:1})])
      Twitter::Media::Photo.any_instance.stub(:media_uri).and_return('src_url_of_media.png')
      image_data = Scrape::Twitter.get_data(@tweet)

      expect(image_data).to be_an(Array)
      expect(image_data[0][:page_url]).to eql(
        'https://twitter.com/wycejezevix/status/454783931636670464'
      )
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

  describe "get_stats function" do
    it "returns stats information from a page_url" do
      page_url = 'https://twitter.com/ogipote/status/419125060968804352'
      client = Scrape::Twitter.get_client
      result = @client.get_stats(page_url)
      expect(result).to be_a(Hash)
      expect(result[:views]).to be_a(Integer)
      expect(result[:favorites]).to be_a(Integer)
    end
  end

end