require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe Scrape::Nico do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  let(:xml) { IO.read(Rails.root.join('spec', 'fixtures', 'nico_api_response.xml')) }

  before do
    IO.any_instance.stub(:puts)           # コンソールに出力しないようにしておく
    Resque.stub(:enqueue).and_return nil  # resqueにenqueueしないように
    @agent = Scrape::Nico.get_client      # Mechanize agentの作成

    url = 'http://seiga.nicovideo.jp/rss/illust/new'
    xml = Nokogiri::XML(open(url))
    item = xml.css('item')[0]
    @page_url = item.css('link').first.content
  end

  describe "scrape method" do
    it "calls scrape_using_api method" do
      FactoryGirl.create(:person_madoka)
      Scrape::Nico.stub(:scrape_using_api).and_return({ scraped: 0, duplicates: 0, avg_time: 0 })
      Scrape::Nico.should_receive(:scrape_using_api)

      Scrape::Nico.scrape(60, true, true)
    end

    it "sleeps with right interval after each scraping" do
      FactoryGirl.create_list(:person_with_word, 5)
      Scrape.should_receive(:sleep).with(10*60)      # (60-10) / 5*1.0
      Scrape.stub(:sleep).and_return nil

      Scrape::Nico.scrape(60, true, false)
    end

    it "raise error when it gets improper argument" do
      FactoryGirl.create(:person_madoka)
      expect { Scrape::Nico.scrape(14, false, true) }.to raise_error(Exception)
    end

    it "exit if another process is running" do
      PidFile.stub(:running?).and_return(true)

      expect {
        Scrape::Nico.scrape(15, false, false)
      }.to raise_error(SystemExit)
    end
  end

  describe "scrape_target_word function" do
    it "calls proper functions" do
      target_word = FactoryGirl.create(:word_with_person)
      Scrape::Nico.should_receive(:scrape_using_api)
      Scrape::Nico.stub(:scrape_using_api).and_return({ scraped: 0, duplicates: 0, avg_time: 0 })
      Scrape::Nico.scrape_target_word target_word
    end
  end
  describe "scrape_using_api function" do
    before do
      stream = File.read(Rails.root.join('spec', 'fixtures', 'nico_api_response.xml'))
      uri = 'http://seiga.nicovideo.jp/api/tagslide/data?page=1&query=まどかわいい'
      FakeWeb.register_uri(:get,
        URI.escape(uri) ,
        body: stream,
        content_type: 'text/xml')
    end

    it "skip if keyword arg is nil" do
      Scrape::Nico.should_not_receive(:get_data)
      Scrape::Nico.scrape_using_api(nil, 5, false)
    end

    it "calls get_data function 'limit' times" do
      limit = 50
      #Scrape::Nico.stub(:get_data).and_return({})
      Scrape::Nico.should_receive(:get_data).exactly(limit).times
      Scrape.stub(:save_image).and_return(1)
      Scrape.should_receive(:save_image).exactly(limit).times

      Scrape::Nico.scrape_using_api('まどかわいい', limit, false)
    end

    it "allows duplicates three times" do
      Scrape::Nico.stub(:get_data).and_return({})
      Scrape::Nico.should_receive(:get_data).exactly(3).times
      Scrape.stub(:save_image).and_return nil
      Scrape.should_receive(:save_image).exactly(3).times

      Scrape::Nico.scrape_using_api('まどかわいい', 3, false)
    end
  end

  describe "get_tags function" do
    it "returns an array of tags" do
      tags = Scrape::Nico.get_tags(['Madoka'])
      expect(tags).to be_an(Array)
      expect(tags.first.name).to eql('Madoka')
    end
    it "uses existing tags if tags are duplicate" do
      image = FactoryGirl.create(:image)
      tag = FactoryGirl.create(:tag)
      image.tags << tag

      tags = Scrape::Nico.get_tags(['鹿目まどか'])
      expect(tags.first.images.first.id).to eql(tag.images.first.id)
    end
  end

  describe "get_contents method" do
    it "creates an image model from image source" do
      #xml = Nokogiri::XML(open('http://seiga.nicovideo.jp/rss/illust/new'))
      #Scrape.should_receive(:save_image)
      #Scrape::Nico.get_contents(@page_url, @agent, @title)
    end

    # 対象の画像URLを開けなかった時、ログに書き出すこと
    it "writes a log when it fails to open the image page" do
      count = Image.count
      url = 'An invalid page url'

      Rails.logger.should_receive(:info)
      Scrape.should_not_receive(:save_image)

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
      expect(result[:views]).to be_a(String)
      expect(result[:favorites]).to be_a(String)
    end
  end


end
