require 'spec_helper'
require "#{Rails.root}/script/scrape"

describe Scrape::Deviant do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    IO.any_instance.stub(:puts)
  end

  describe "is_adult method" do
    it "should ignore a mature content" do
      url = 'http://ugly-ink.deviantart.com/art/HAPPY-HALLOWEEN-266750603'
      html = Nokogiri::HTML(open(url))
      Scrape::Deviant.is_adult(html).should eq(true)
    end

    it "should return false with non-mature contents" do
      url = 'http://www.deviantart.com/art/Crossing-4-437129901'
      html = Nokogiri::HTML(open(url))
      Scrape::Deviant.is_adult(html).should eq(false)
    end
  end

  describe "get_contents method" do
    it "should create an image model from image source" do
      Scrape::Deviant.stub(:is_adult).and_return(false)
      count = Image.count

      #xml = Nokogiri::XML(open('http://backend.deviantart.com/rss.xml?type=deviation&q=boost%3Apopular+max_age%3A24h+in%3Amanga%2Fdigital+anime'))
      #Scrape::Deviant.get_contents(xml.css("item")[1])
      url = 'http://www.deviantart.com/art/Crossing-4-437129901'
      Scrape::Deviant.get_contents(url, 'test')
      Image.count.should eq(count+1)
    end

    it "should not create an image model from mature image" do
      Scrape::Deviant.stub(:is_adult).and_return(true)
      count = Image.count
      #xml = Nokogiri::XML(open('http://backend.deviantart.com/rss.xml?type=deviation&q=boost%3Apopular+max_age%3A24h+in%3Amanga%2Fdigital+anime'))
      #Scrap::Deviant.get_contents(xml.css("item")[1])
      url = 'http://www.deviantart.com/art/Crossing-4-437129901'
      Scrape::Deviant.get_contents(url, 'test')
      Image.count.should eq(count)
    end

    # 対象URLを開けなかったとき
    it "should write a log when it fails to open the image page" do
      Rails.logger.should_receive(:info).with('Image model saving failed.')
      Scrape.should_not_receive(:save_image)

      url = 'not_existed_url'
      Scrape::Deviant.get_contents(url, 'test')
    end
  end

  describe "scrape method" do
    it "should call get_contents method at least 1 time" do
      Scrape::Deviant.stub(:get_contents).and_return()
      Scrape::Deviant.should_receive(:get_contents).at_least(20).times

      Scrape::Deviant.scrape()
    end
  end
end