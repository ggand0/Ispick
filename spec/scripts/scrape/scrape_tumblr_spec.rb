require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_tumblr"

describe Scrape::Tumblr do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  let(:response) { IO.read(Rails.root.join('spec', 'fixtures', 'tumblr_api_response')) }

  before do
    allow_any_instance_of(IO).to receive(:puts)             # Surpress console outputs
    allow(Resque).to receive(:enqueue).and_return nil       # Prevent Resque.enqueue method from running
    @client = Scrape::Tumblr.new(nil, 5)
    @response = JSON.parse(response)['response']
    @logger = Logger.new('log/scrape_tumblr_cron.log')
  end

  describe "scrape method" do
    it "calls scrape_target_words function" do
      FactoryGirl.create(:person_madoka)
      allow(@client).to receive(:scrape_target_words).and_return nil
      expect(@client).to receive(:scrape_target_words)

      @client.scrape(60)
    end
  end

  describe "scrape_target_word method" do
    it "calls scrape_using_api method" do
      target_word = FactoryGirl.create(:word_with_person)
      allow(@client).to receive(:scrape_using_api).and_return({ scraped: 0, duplicates: 0, avg_time: 0 })
      expect(@client).to receive(:scrape_using_api)
      @client.scrape_target_word(1, target_word)
    end
  end


  describe "scrape_using_api function" do
    it "calls proper functions" do
      target_word = FactoryGirl.create(:word_with_person)
      allow_any_instance_of(Tumblr::Client).to receive(:tagged).and_return(@response)

      expect(Scrape::Tumblr).to receive(:get_data).exactly(5).times.and_return({})
      expect(Scrape::Client).to receive(:save_image).exactly(5).times.and_return(1)
      result = @client.scrape_using_api(target_word)
      expect(result).to be_a(Hash)
      expect(result[:scraped]).to eq(5)
      expect(result[:duplicates]).to eq(0)
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
        "photos"=>[{
          "alt_sizes"=>[{"width"=>518,"height"=>800,"url"=>"http:\/\/24.media.tumblr.com\/6105c6ed9ec401e0bb756eb0fe29ffca\/tumblr_n4q40pWU3T1s7jcyvo1_1280.jpg"}],
          "original_size"=>{
            "width"=>697,
            "height"=>981,
            "url"=>"http://37.media.tumblr.com/9cbde1a610fd826c87600caa3372e176/tumblr_n2sk2cFwOB1qdwsovo1_1280.jpg"
          }}]
      }

      image_data = Scrape::Tumblr.get_data(image)
      puts image_data.inspect
      expect(image_data).to be_a(Hash)
      expect(image_data[:original_width]).to eq(697)
      expect(image_data[:original_height]).to eq(981)
    end
  end


  describe "get_client function" do
    it "returns tumblr client" do
      client = Scrape::Tumblr.get_client
      expect(client.class).to eq(Tumblr::Client)
    end
  end

end