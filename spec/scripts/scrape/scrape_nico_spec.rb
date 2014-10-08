require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/client"

describe Scrape::Nico do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  let(:xml) { IO.read(Rails.root.join('spec', 'fixtures', 'nico_api_response.xml')) }
  let(:limit) { 10 }

  before do
    IO.any_instance.stub(:puts)           # コンソールに出力しないようにしておく
    Resque.stub(:enqueue).and_return nil  # resqueにenqueueしないように
    @agent = Scrape::Nico.get_client      # Mechanize agentの作成
    @client = Scrape::Nico.new(nil, limit)

    url = 'http://seiga.nicovideo.jp/rss/illust/new'
    xml = Nokogiri::XML(open(url))
    item = xml.css('item')[0]
    @page_url = item.css('link').first.content
  end

  describe "scrape method" do
    it "calls scrape_using_api method" do
      FactoryGirl.create(:word_with_person)

      @client.stub(:scrape_target_words).and_return nil
      expect(@client).to receive(:scrape_target_words)

      @client.scrape(60)
    end
  end

  describe "scrape_target_word function" do
    it "calls proper functions" do
      target_word = FactoryGirl.create(:word_with_person)

      @client.stub(:scrape_using_api).and_return({ scraped: 0, duplicates: 0, avg_time: 0 })
      expect(@client).to receive(:scrape_using_api)

      @client.scrape_target_word(1, target_word)
    end
  end

  describe "scrape_using_api function" do
    before do
      stream = File.read(Rails.root.join('spec', 'fixtures', 'nico_api_response.xml'))
      #uri = 'http://seiga.nicovideo.jp/api/tagslide/data?page=1&query=まどかわいい'
      uri = 'http://seiga.nicovideo.jp/api/tagslide/data?page=1&query=鹿目まどか1'
      FakeWeb.register_uri(:get,
        URI.escape(uri),
        body: stream,
        content_type: 'text/xml')
    end

    it "skip if keyword arg is nil" do
      Scrape::Nico.should_not_receive(:get_data)
      @client.scrape_using_api(nil)
    end

    it "calls get_data function 'limit' times" do
      Scrape::Nico.stub(:get_data).and_return({})

      target_word = FactoryGirl.create(:word_with_person)
      puts target_word.inspect
      Scrape::Client.stub(:save_image).and_return(1)
      result = @client.scrape_using_api(target_word)
      puts result
      Scrape::Nico.should_receive(:get_data).exactly(limit - result[:skipped]).times

      Scrape::Client.should_receive(:save_image).exactly(limit - result[:skipped]).times

      puts result = @client.scrape_using_api(target_word)
    end

    it "allows duplicates three times" do
      Scrape::Nico.stub(:get_data).and_return({})
      Scrape::Nico.should_receive(:get_data).exactly(3).times
      Scrape::Client.stub(:save_image).and_return nil
      Scrape::Client.should_receive(:save_image).exactly(3).times
      target_word = FactoryGirl.create(:word_with_person)

      @client.scrape_using_api(target_word)
    end
  end



  describe "get_contents method" do
    # 対象の画像URLを開けなかった時、ログに書き出すこと
    it "writes a log when it fails to open the image page" do
      count = Image.count
      url = 'An invalid page url'

      Rails.logger.should_receive(:info)
      Scrape::Client.should_not_receive(:save_image)

      Scrape::Nico.get_contents(url, @agent, @title)
    end

    it "ignores adulut pages" do
      page_url = 'http://seiga.nicovideo.jp/seiga/im3833006'

      Scrape.should_not_receive(:save_image)
      Scrape::Nico.get_contents(page_url, @agent, @title)
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
