require 'spec_helper'
require "#{Rails.root}/script/scrap"

describe Scrap::Pixiv do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    IO.any_instance.stub(:puts)
  end

  describe "get_contents method" do
    it "should create an image model from image source" do
      count = Image.count
      uri = URI.parse('http://spapi.pixiv.net/iphone/search.php?s_mode=s_tag&word=%E3%81%BE%E3%81%A9%E3%81%8B%E3%82%8F%E3%81%84%E3%81%84&PHPSESSID=0')
      result = Net::HTTP.get(uri)
      lines = result.split("\n")

      Scrap::Pixiv.get_contents(lines[0])
      Image.count.should eq(count+1)
    end
  end

  describe "scrap method" do
    it "should call get_contents method at least 1 time" do
      Scrap::Pixiv.stub(:get_contents).and_return()
      Scrap::Pixiv.should_receive(:get_contents).at_least(20).times

      Scrap::Pixiv.scrap()
    end
  end
end