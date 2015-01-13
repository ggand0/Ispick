require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_zerochan"

describe Scrape::Zerochan do
  # TODO: Use fixture so to test codes without network connection
  #let(:response) { IO.read(Rails.root.join('spec', 'fixtures', 'zerochan_rss.html')) }

  before do
    #IO.any_instance.stub(:puts)                           # Surpress console outputs
    allow(Resque).to receive(:enqueue).and_return nil     # Prevent Resque.enqueue method from running
    @client = Scrape::Zerochan.new(nil, 5)
    @logger = Logger.new('log/scrape_zerochan_cron.log')
    #@response = JSON.parse(response)['response']

    subject.instance_variable_set(:@limit, 5)
  end


  # =================
  #    Main methods
  # =================
  describe "scrape method" do
    it "calls scrape_target_words function" do
      FactoryGirl.create(:person_madoka)
      allow(@client).to receive(:scrape_RSS).and_return nil
      expect(@client).to receive(:scrape_RSS)

      @client.scrape(60)
    end
  end

  describe "scrape_using_api method" do
    it "calls valid methods" do
      target_word = TargetWord.create(name: 'Kaname Madoka')
      allow(@client).to receive(:scrape_page).and_return({scraped: 6})

      result = @client.scrape_using_api(target_word)
    end
  end

  describe "scrape_page method" do
    it "sleep 1 sec after scraping" do
      page = @client.get_search_result('Kaname Madoka')
      url = page.uri.to_s
      page = Nokogiri::HTML(open(url))
      result_hash = Scrape.get_result_hash

      allow(@client).to receive(:sleep).and_return 1
      allow(@client).to receive(:get_data)
      allow(Scrape::Client).to receive(:save_image).and_return(1)
      expect(@client).to receive(:sleep)

      result = @client.scrape_page(page, result_hash, nil, nil, nil, nil)
    end
  end



  # =================
  #   Utility methods
  # =================
  describe "get_search_result method" do
    it "returns a valid Mechanize::Page object" do
      result = @client.get_search_result('Kaname Madoka')
    end
  end

  describe "get_time method" do
    it "returns a valid Time object" do
      page_url = 'http://www.zerochan.net/1228175'
      page = Nokogiri::HTML(open(page_url))
      time = Scrape::Zerochan.get_time(page)
      expect(time.to_s).to eq('2012-08-14 19:52:31 +0900')
    end

    it "returns a valid Time object" do
      page_url = 'http://www.zerochan.net/1822478'
      page = Nokogiri::HTML(open(page_url))
      time = Scrape::Zerochan.get_time(page)
      expect(time.to_s).to eq('2015-01-05 08:36:12 +0900')
    end

    it "returns a valid Time object" do
      page_url = 'http://www.zerochan.net/246100'
      page = Nokogiri::HTML(open(page_url))
      time = Scrape::Zerochan.get_time(page)
      expect(time.to_s).to eq('')
    end
  end


  describe "get_data method" do
    it "returns a valid hash" do
      page_url = 'http://www.zerochan.net/1810800'
      xml = Nokogiri::XML(open(page_url))

      result = @client.get_data(xml, page_url)
      expect(result).to be_a(Hash)
      expect(result[:original_width]).to eq('1473')
      expect(result[:original_height]).to eq('1217')
    end
  end

end