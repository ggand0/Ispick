require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe Scrape::Piapro do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    #IO.any_instance.stub(:puts)

    @agent = Scrape::Piapro.login()
  end

  describe "get_illust_html function" do
    it "returns Nokogiri::HTML object" do
      html = Nokogiri::HTML(open('http://piapro.jp/illust/?categoryId=3'))
      item = html.css("a[class='i_image']")[0]

      page = Scrape::Piapro.get_illust_html(item)
      expect(page).to be_a(Nokogiri::HTML::Document)
    end

    # 対象URLを開けなかった時にログに書く事
    it "writes a log when it fails to open the image page" do
      Rails.logger.should_receive(:info).with('Could not open the page.')
      Scrape.should_not_receive(:save_image)

      url = 'not_existed_url'
      Scrape::Piapro.get_illust_html(url)
    end
  end

  describe "get_contents function" do
    it "creates an image model from image source" do
      count = Image.count
      #html = Nokogiri::HTML(open('http://piapro.jp/illust/?categoryId=3'))
      #Scrape::Piapro.get_contents(html.css("a[class='i_image']")[0])

      # save_image functionが呼ばれるはず
      Scrape.stub(:save_image).and_return
      Scrape.should_receive(:save_image)

      # イラスト表示ページ
      html = Nokogiri::HTML(open('http://piapro.jp/t/uvW_'))
      url = 'http://piapro.jp/t/mdHE'
      Scrape::Piapro.get_contents(url, @agent, { title: 'test' })
    end

    # Tag
    it "scrape multiple tags from the page" do
      # 複数タグが登録されているイラスト
      #html = Nokogiri::HTML(open('http://piapro.jp/t/uvW_'))
      #Scrape::Piapro.get_contents(html)
    end
  end

  describe "login function" do
    it "returns mechanize agent" do
      agent = Scrape::Piapro.login()
      puts agent.methods
      puts agent.status
      #expect(agent).to be_a(Mechanize)
      expect(agent).to be_a(Hash)
    end
  end

  describe "scrape function" do
    it "should call get_contents method at least 30 time" do
      Scrape::Piapro.stub(:get_contents).and_return()
      Scrape::Piapro.should_receive(:get_contents).at_least(30).times

      Scrape::Piapro.scrape()
    end
  end
end