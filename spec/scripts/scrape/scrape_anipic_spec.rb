require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_anipic"

describe Scrape::Anipic do
  let(:response) { IO.read(Rails.root.join('spec', 'fixtures', 'anipic_rss.html')) }
  before do
    #IO.any_instance.stub(:puts)             # Surpress console outputs
    Resque.stub(:enqueue).and_return nil    # Prevent Resque.enqueue method from running
    @client = Scrape::Anipic.new(nil, 5)
    #@response = JSON.parse(response)['response']
    @logger = Logger.new('log/scrape_anipic_cron.log')
  end

  describe "scrape method" do
    it "calls scrape_target_words function" do
      FactoryGirl.create(:person_madoka)
      @client.stub(:scrape_target_words).and_return nil
      expect(@client).to receive(:scrape_target_words)

      @client.scrape(60)
    end
  end

  describe "scrape_using_api method" do
    it "calls valid methods" do
      target_word = FactoryGirl.create(:target_word)
      query = 'Kaname Madoka'
      result = @client.get_search_result(query)
      expect(@client).to receive(:get_search_result).exactly(1).times.
        and_return(result)
      expect(@client).to receive(:get_data).at_least(1).times.
        and_return({})
      expect(Scrape::Client).to receive(:save_image).at_least(1).times

      result_hash = @client.scrape_using_api(target_word)
      puts result_hash.inspect
    end
  end

  describe "is_range method" do
    it "returns true when target's in range" do
      target =  Date.today
      puts result = Scrape::Anipic.is_range(target)
      expect(result).to eq(true)
    end

    it "returns false otherwise" do
      target =  Date.today - 3.day
      puts result = Scrape::Anipic.is_range(target)
      expect(result).to eq(false)
    end
  end

  describe "scrape_RSS method" do
    it "stops scraping if it's out of range" do

    end
  end

  describe "get_search_result method" do
    it "returns proper result" do
      target_word = FactoryGirl.create(:target_word)
      query = Scrape.get_query(target_word)

      result = @client.get_search_result(query)
      expect(result).to be_a(Mechanize::Page)
      expect(result.links.count).to be > 0
    end
  end

  describe "get_time class method" do
    it "returns a valid time string" do
      time = '  8/14/14, 2:52 PM'
      time = Scrape::Anipic.get_time(time)

      expect(time).to eq('2014/8/14/14:52')

      time = '8/16/14, 5:31 PM'
      time = Scrape::Anipic.get_time(time)

      expect(time).to eq('2014/8/16/17:31')

      time = '8/16/14, 12:31 PM'
      time = Scrape::Anipic.get_time(time)

      expect(time).to eq('2014/8/16/0:31')
    end
  end


  describe "get_data method" do
    it "returns a valid hash" do
      page_url = 'http://anime-pictures.net/pictures/view_post/378091?lang=en'
      xml = Nokogiri::XML(open(page_url))

      result = @client.get_data(xml, page_url)
      expect(result).to be_a(Hash)
      expect(result[:original_width]).to eq('1200')
      expect(result[:original_height]).to eq('1105')
    end
  end

end