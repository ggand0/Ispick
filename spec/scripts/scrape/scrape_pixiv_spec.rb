require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe Scrape::Pixiv do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    allow_any_instance_of(IO).to receive(:puts)
    allow(Resque).to receive(:enqueue).and_return nil # resqueにenqueueしないように
  end

  describe "get_contents method" do
    it "should create an image model from image source" do
      count = Image.count
      uri = URI.parse('http://spapi.pixiv.net/iphone/search.php?s_mode=s_tag&word=%E3%81%BE%E3%81%A9%E3%81%8B%E3%82%8F%E3%81%84%E3%81%84&PHPSESSID=0')
      result = Net::HTTP.get(uri)
      lines = result.split("\n")

      Scrape::Pixiv.get_contents(lines[0])
      expect(Image.count).to eq(count+1)
    end
  end

  describe "scrape method" do
    it "should call get_contents method at least 1 time" do
      allow(Scrape::Pixiv).to receive(:get_contents).and_return nil
      expect(Scrape::Pixiv).to receive(:get_contents).at_least(20).times

      Scrape::Pixiv.scrape
    end
  end
end