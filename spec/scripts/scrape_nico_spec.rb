require 'spec_helper'
require "#{Rails.root}/script/scrape"

describe Scrape::Nico do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    # コンソールに出力しないようにしておく
    IO.any_instance.stub(:puts)
  end

  describe "get_contents method" do
    # itemタグを参照するオブジェクトを渡した時に、新規Imageが保存されること
    it "should create an image model from image source" do
      count = Image.count
      xml = Nokogiri::XML(open('http://seiga.nicovideo.jp/rss/illust/new'))

      Scrape::Nico.get_contents(xml.css("item")[0])
      Image.count.should eq(count+1)
    end

    # 対象の画像URLを開けなかった時、ログに書き出すこと
    it "should write a log when it fails to open the image page" do
      count = Image.count
      xml = Nokogiri::XML(open('http://google.com'))# 例えば、画像と無関係なURL

      Rails.logger.should_receive(:info).with('Image model saving failed.')
      Scrape.should_not_receive(:save_image)

      Scrape::Nico.get_contents(xml.css("item")[0])
    end
  end

  describe "scrape method" do
    # 少なくとも20回はget_contentsメソッドを呼び出すこと
    it "should call get_contents method at least 20 time" do
      Scrape::Nico.stub(:get_contents).and_return()
      Scrape::Nico.should_receive(:get_contents).at_least(20).times

      Scrape::Nico.scrape()
    end
  end
end