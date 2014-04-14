require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe Scrape::Nico do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    # コンソールに出力しないようにしておく
    IO.any_instance.stub(:puts)

    # resqueにenqueueしないように
    Resque.stub(:enqueue).and_return

    # Mechanize agentの作成
    @agent = Mechanize.new
    @agent.ssl_version = 'SSLv3'
    @agent.post('https://secure.nicovideo.jp/secure/login?site=seiga',
      'mail' => CONFIG['nico_email'],'password' => CONFIG['nico_password'])

    url = 'http://seiga.nicovideo.jp/rss/illust/new'
    xml = Nokogiri::XML(open(url))
    item = xml.css('item')[0]
    @page_url = item.css('link').first.content
    @title = item.css('title').first.content
    puts @page_url
  end

  describe "is_adult function" do
    it "returns true with an adult page" do
      page_url = 'http://seiga.nicovideo.jp/seiga/im3833006'
      page = @agent.get(page_url)
      expect(Scrape::Nico.is_adult(page)).to eq(true)
    end

    it "returns false with a general page" do
      page_url = 'http://seiga.nicovideo.jp/seiga/im1276537?track=seiga_illust_keyword'
      page = @agent.get(page_url)
      expect(Scrape::Nico.is_adult(page)).to eq(false)
    end
  end

  describe "get_tags function" do

  end

  describe "get_stats function" do
    it "returns stats hash from a certain page" do
      page_url = 'http://seiga.nicovideo.jp/seiga/im3858537'
      stats = Scrape::Nico.get_stats(page_url)
      expect(stats).to be_a(Hash)
    end
  end

  describe "get_contents method" do
    # itemタグを参照するオブジェクトを渡した時に、新規Imageが保存されること
    it "should create an image model from image source" do
      count = Image.count
      xml = Nokogiri::XML(open('http://seiga.nicovideo.jp/rss/illust/new'))

      Scrape.should_receive(:save_image)
      Scrape::Nico.get_contents(@page_url, @agent, @title)
      #Image.count.should eq(count+1)
    end

    # 対象の画像URLを開けなかった時、ログに書き出すこと
    it "should write a log when it fails to open the image page" do
      count = Image.count
      url = 'An invalid page url'
      #xml = Nokogiri::XML(open(url))# 例えば、画像と無関係なURL

      Rails.logger.should_receive(:info).with('Could not open the page.')
      Scrape.should_not_receive(:save_image)

      Scrape::Nico.get_contents(url, @agent, @title)
    end

    it "ignores adulut pages" do
      page_url = 'http://seiga.nicovideo.jp/seiga/im3833006'

      Scrape.should_not_receive(:save_image)
      Scrape::Nico.get_contents(page_url, @agent, @title)
    end
  end

  describe "scrape method" do
    # 少なくとも20回はget_contentsメソッドを呼び出すこと
    it "should call get_contents method at least 50 time" do
      limit = 50
      FactoryGirl.create(:person_madoka)

      Scrape::Nico.stub(:get_contents).and_return()
      Scrape::Nico.should_receive(:get_contents).at_least(limit).times

      Scrape::Nico.scrape()
    end
  end
end