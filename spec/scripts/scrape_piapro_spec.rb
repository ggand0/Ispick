require 'spec_helper'
require "#{Rails.root}/script/scrape"

describe Scrape::Piapro do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    IO.any_instance.stub(:puts)
  end

  describe "get_contents method" do
    it "should create an image model from image source" do
      count = Image.count
      html = Nokogiri::HTML(open('http://piapro.jp/illust/?categoryId=3'))

      Scrape::Piapro.get_contents(html.css("a[class='i_image']")[0])
      Image.count.should eq(count+1)
    end

    # 対象URLを開けなかった時にログに書く事
    it "should write a log when it fails to open the image page" do
      Rails.logger.should_receive(:info).with('Image model saving failed.')
      Scrape.should_not_receive(:save_image)

      url = 'not_existed_url'
      Scrape::Piapro.get_contents(url)
    end
  end

  describe "scrape method" do
    it "should call get_contents method at least 30 time" do
      Scrape::Piapro.stub(:get_contents).and_return()
      Scrape::Piapro.should_receive(:get_contents).at_least(30).times

      Scrape::Piapro.scrape()
    end
  end
end