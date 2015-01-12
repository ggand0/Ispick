require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe Scrape::Deviant do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    allow_any_instance_of(IO).to receive(:puts)             # Surpress console outputs
    allow(Resque).to receive(:enqueue).and_return nil       # Prevent Resque.enqueue method from running
  end


  describe "is_adult method" do
    it "should return true with mature content" do
      url = 'http://ugly-ink.deviantart.com/art/HAPPY-HALLOWEEN-266750603'
      html = Nokogiri::HTML(open(url))
      expect(Scrape::Deviant.is_adult(html)).to eq(true)
    end

    it "should return false with non-mature contents" do
      url = 'http://www.deviantart.com/art/Crossing-4-437129901'
      html = Nokogiri::HTML(open(url))
      expect(Scrape::Deviant.is_adult(html)).to eq(false)
    end
  end

  describe "get_contents method" do
    before do
      @image_data = {
        title: 'test',
        page_url: 'http://www.deviantart.com/art/Crossing-4-437129901'
      }
    end

    it "should create an image model from an image source" do
      allow(Scrape::Deviant).to receive(:is_adult).and_return(false)
      count = Image.count

      Scrape::Deviant.get_contents(@image_data)
      expect(Image.count).to eq(count+1)
    end

    it "should NOT create an image model from a mature image" do
      allow(Scrape::Deviant).to receive(:is_adult).and_return(true)
      count = Image.count

      url = 'http://www.deviantart.com/art/Crossing-4-437129901'
      Scrape::Deviant.get_contents(@image_data)
      expect(Image.count).to eq(count)
    end

    it "should write a log when it fails to open the image page" do
      expect(Rails.logger).to receive(:info).with('Image model saving failed.')
      expect(Scrape).not_to receive(:save_image)

      url = 'not_existed_url'
      Scrape::Deviant.get_contents({title: 'test', src_url: url})
    end
  end

  describe "scrape method" do
    it "should call get_contents method at least 20 time" do
      allow(Scrape::Deviant).to receive(:get_contents).and_return nil
      expect(Scrape::Deviant).to receive(:get_contents).at_least(20).times

      Scrape::Deviant.scrape()
    end
  end


  describe "get_stats function" do
    it "returns updated stats information" do
      page_url = 'http://www.deviantart.com/art/Madoka-201395121'
      result = Scrape::Deviant.get_stats(page_url)
      expect(result).to be_a(Hash)
    end

    it "writes a log when it fails to open the page" do
      expect(Rails.logger).to receive(:info).with('Could not open the page.')

      url = 'not_existed_url'
      Scrape::Deviant.get_stats(url)
    end
  end
end