require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_tumblr"

describe Scrape::Tumblr do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  let(:response) { IO.read(Rails.root.join('spec', 'fixtures', 'tumblr_api_response')) }
  before do
    IO.any_instance.stub(:puts)             # コンソールに出力しないようにしておく
    Resque.stub(:enqueue).and_return nil    # resqueにenqueueしないように
    #@client = Scrape::Tumblr.get_client()
    @client = Scrape::Tumblr.new
    #Rails.stub_chain(:logger, :debug).and_return(logger_mock)
    @response = JSON.parse(response)['response']
  end

  describe "scrape function" do
    it "calls scrape_target_words function" do
      FactoryGirl.create(:person_madoka)
      Scrape.should_receive(:scrape_target_words)
      Scrape::Tumblr.scrape(60, true, true)
    end

    it "skips keywords with nil or empty value" do
      nil_word = TargetWord.new
      nil_word.save!
      Scrape::Tumblr.stub(:scrape_using_api).and_return nil
      Scrape::Tumblr.should_not_receive(:scrape_using_api)

      Scrape::Tumblr.scrape(60, true, true)
    end


    it "sleeps with right interval after each scraping" do
      FactoryGirl.create_list(:target_word, 5)
      Scrape.should_receive(:sleep).with(10*60)      # (60-10) / 5*1.0
      Scrape.stub(:sleep).and_return nil

      Scrape::Tumblr.scrape(60, true, false)
    end

    it "raise error when it gets improper argument" do
      FactoryGirl.create(:person_madoka)
      expect { Scrape::Tumblr.scrape(14, false, true) }.to raise_error(Exception)
    end

    it "exit if another process is running" do
      PidFile.stub(:running?).and_return(true)

      expect {
        Scrape::Tumblr.scrape(15, false, false)
      }.to raise_error(SystemExit)
    end
  end

  describe "scrape_target_word function" do
    it "calls scrape_using_api function" do
      target_word = FactoryGirl.create(:word_with_person)
      Scrape::Tumblr.should_receive(:scrape_using_api)
      Scrape::Tumblr.stub(:scrape_using_api).and_return({ scraped: 0, duplicates: 0, avg_time: 0 })
      logger = Logger.new('log/scrape_tumblr_cron.log')

      Scrape::Tumblr.scrape_target_word target_word, logger
    end
  end

  describe "scrape_using_api function" do
    it "calls proper functions" do
      Tumblr::Client.any_instance.stub(:tagged).and_return(@response)
      # get_data functionをmockすると何故かcallされなくなるので、save_imageのみ見る
      #Scrape::Tumblr.should_receive(:get_data).exactly(5).times
      Scrape.should_receive(:save_image).exactly(5).times
      logger = Logger.new('log/scrape_tumblr_cron.log')
      target_word = FactoryGirl.create(:word_with_person)

      Scrape::Tumblr.scrape_using_api(target_word, 5, logger)
    end
  end

  describe "get_data function" do
    it "returns image_data hash" do
      image = {
        "blog_name"=>"realotakuman",
        "id"=>80263089672,
        "post_url"=>"http://realotakuman.tumblr.com/post/80263089672/pixiv",
        "date"=>"2014-03-21 14:54:12 GMT",
        "tags"=>["アナログ", "VOICEROID+", "結月ゆかり", "弦巻マキ"],
        "note_count"=>3,
        "caption"=>"blah blah",
        "photos"=>[{"original_size"=>{
          "width"=>697,
          "height"=>981,
          "url"=>"http://37.media.tumblr.com/9cbde1a610fd826c87600caa3372e176/tumblr_n2sk2cFwOB1qdwsovo1_1280.jpg"
          }}]
      }

      image_data = Scrape::Tumblr.get_data(image)
      expect(image_data).to be_a(Hash)
    end
  end

  describe "get_tags function" do
    it "returns an array of tags" do
      tags = Scrape::Tumblr.get_tags(['Madoka'])
      expect(tags).to be_an(Array)
      expect(tags.first.name).to eql('Madoka')
    end
    it "uses existing tags if tags are duplicate" do
      image = FactoryGirl.create(:image_with_specific_tags)

      tags = Scrape::Tumblr.get_tags(['鹿目まどか'])
      puts tags.inspect
      puts tags.first.images
      expect(tags.first.images.first.id).to eql(image.id)
    end
  end

  describe "get_stats function" do
    it "returns a hash with favorites value" do
      post = FactoryGirl.build(:tumblr_api_response)
      Tumblr::Client.any_instance.stub(:posts).and_return(post[:response])
      page_url = 'http://realotakuman.tumblr.com/post/84103502875/twitter-kiya-si-http-t-co-mq1t'
      stats = Scrape::Tumblr.get_stats(@client, page_url)

      expect(stats).to be_a(Hash)
      expect(stats[:favorites]).to eql(post[:response]['posts'][0]['note_count'])
    end
  end

  describe "get_client function" do
    it "returns tumblr client" do
      client = Scrape::Tumblr.get_client
      client.class.should eq(Tumblr::Client)
    end
  end

  describe "get_favorites function" do
    it "returns favorites count of the post" do
      page_url = 'http://senshi.org/post/82331944259/miku-x-cat-by-kenji'
      puts result = Scrape::Tumblr.get_favorites(page_url)
      expect(result).not_to eql(nil)
    end
  end
end