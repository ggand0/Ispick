require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/client"

describe Scrape::Nico do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  #let(:xml) { IO.read(Rails.root.join('spec', 'fixtures', 'nico_api_response.xml')) }
  let(:limit) { 10 }

  before do
    allow_any_instance_of(IO).to receive(:puts)             # Surpress console outputs
    allow(Resque).to receive(:enqueue).and_return nil    # Prevent Resque.enqueue method from running
    @agent = Scrape::Nico.get_client        # Create a Mechanize agent
    @client = Scrape::Nico.new(nil, limit)

    stream = File.read(Rails.root.join('spec', 'fixtures', 'nico_api_response.xml'))
    uri = 'http://seiga.nicovideo.jp/api/tagslide/data?page=1&query=鹿目まどか1'
    FakeWeb.register_uri(:get,
      URI.escape(uri),
      body: stream,
      content_type: 'text/xml')
    xml = Nokogiri::XML(open(URI.escape(uri)))
    @item = xml.search('image')[0]
    @page_url =  'http://seiga.nicovideo.jp/seiga/im3063004'
  end

  describe "scrape method" do
    it "calls scrape_using_api method" do
      FactoryGirl.create(:word_with_person)

      allow(@client).to receive(:scrape_target_words).and_return nil
      expect(@client).to receive(:scrape_target_words)

      @client.scrape(60)
    end
  end

  describe "scrape_target_word function" do
    it "calls proper functions" do
      target_word = FactoryGirl.create(:word_with_person)

      allow(@client).to receive(:scrape_using_api).and_return({ scraped: 0, duplicates: 0, avg_time: 0 })
      expect(@client).to receive(:scrape_using_api)

      @client.scrape_target_word(1, target_word)
    end
  end


  describe "scrape_using_api function" do
=begin
    before do
      stream = File.read(Rails.root.join('spec', 'fixtures', 'nico_api_response.xml'))
      #uri = 'http://seiga.nicovideo.jp/api/tagslide/data?page=1&query=まどかわいい'
      uri = 'http://seiga.nicovideo.jp/api/tagslide/data?page=1&query=鹿目まどか1'
      FakeWeb.register_uri(:get,
        URI.escape(uri),
        body: stream,
        content_type: 'text/xml')
    end
=end

    it "skip if keyword arg is nil" do
      expect(Scrape::Nico).not_to receive(:get_data)
      @client.scrape_using_api(nil)
    end

    it "calls get_data function '@limit' times" do
      target_word = FactoryGirl.create(:word_with_person)
      #Scrape.stub(:get_query).and_return('Madoka Kaname')
      allow(Scrape::Nico).to receive(:get_data).and_return({})
      allow(Scrape::Client).to receive(:save_image).and_return(1)

      result = @client.scrape_using_api(target_word)
      expect(Scrape::Nico).to receive(:get_data).exactly(limit - result[:skipped]).times
      expect(Scrape::Client).to receive(:save_image).exactly(limit - result[:skipped]).times

      puts result = @client.scrape_using_api(target_word)
    end

    it "allows duplicates three times" do
      target_word = FactoryGirl.create(:word_with_person)
      allow(Scrape::Nico).to receive(:get_data).and_return({})
      allow(Scrape::Client).to receive(:save_image).and_return nil
      expect(Scrape::Nico).to receive(:get_data).exactly(3).times
      expect(Scrape::Client).to receive(:save_image).exactly(3).times

      @client.scrape_using_api(target_word)
    end
  end

  describe "get_data method" do
    it "returns a hash that has valid attributes" do
      result = Scrape::Nico.get_data(@item)
      puts result.inspect
      expect(result).to be_a(Hash)
      expect(result[:site_name]).to eq('nicoseiga')
      expect(result[:original_width]).to eq(443)
      expect(result[:original_height]).to eq(600)
    end
  end


  describe "get_contents method" do
    # 対象の画像URLを開けなかった時、ログに書き出すこと
    it "writes a log when it fails to open the image page" do
      count = Image.count
      url = 'An invalid page url'

      expect(Rails.logger).to receive(:info)
      expect(Scrape::Client).not_to receive(:save_image)

      Scrape::Nico.get_contents(url, @client, @title)
    end

    it "ignores adulut pages" do
      page_url = 'http://seiga.nicovideo.jp/seiga/im3833006'

      expect(Scrape).not_to receive(:save_image)
      Scrape::Nico.get_contents(page_url, @client, @title)
    end
  end

  describe "get_stats function" do
    it "returns stats of the image" do
      image = FactoryGirl.create(:image_nicoseiga)
      puts result = Scrape::Nico.get_stats(@agent, image.page_url)
      expect(result).to be_a(Hash)
      expect(result[:original_view_count]).to be_a(String)
      expect(result[:original_favorite_count]).to be_a(String)
    end
  end


end
