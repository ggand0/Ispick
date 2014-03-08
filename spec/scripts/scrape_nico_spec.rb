require 'spec_helper'
require "#{Rails.root}/script/scrape"

describe Scrape::Nico do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    IO.any_instance.stub(:puts)
  end

  describe "get_contents method" do
    it "should create an image model from image source" do
      count = Image.count
      xml = Nokogiri::XML(open('http://seiga.nicovideo.jp/rss/illust/new'))

      Scrape::Nico.get_contents(xml.css("item")[0])
      Image.count.should eq(count+1)
    end
  end

  describe "scrape method" do
    it "should call get_contents method at least 1 time" do
      Scrape::Nico.stub(:get_contents).and_return()
      Scrape::Nico.should_receive(:get_contents).at_least(20).times

      Scrape::Nico.scrape()
    end
  end
end