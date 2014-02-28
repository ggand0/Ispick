require 'spec_helper'
require "#{Rails.root}/script/scrap"

describe Scrap::Piapro do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    IO.any_instance.stub(:puts)
  end

  describe "get_contents method" do
    it "should create an image model from image source" do
      count = Image.count
      html = Nokogiri::HTML(open('http://piapro.jp/illust/?categoryId=3'))

      Scrap::Piapro.get_contents(html.css("a[class='i_image']")[0])
      Image.count.should eq(count+1)
    end
  end

  describe "scrap method" do
    it "should call get_contents method at least 1 time" do
      Scrap::Piapro.stub(:get_contents).and_return()
      Scrap::Piapro.should_receive(:get_contents).at_least(30).times

      Scrap::Piapro.scrap()
    end
  end
end