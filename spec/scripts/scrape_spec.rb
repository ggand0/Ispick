require 'spec_helper'
require "#{Rails.root}/script/scrape"

describe Scrape do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    IO.any_instance.stub(:puts)
  end

  describe "scrape_all method" do
    # 全てのスクリプトを呼び出す事
    it "runs all scraping script" do
      Scrape::Nico.stub(:scrape).and_return()
      Scrape::Piapro.stub(:scrape).and_return()
      Scrape::Pixiv.stub(:scrape).and_return()
      Scrape::Deviant.stub(:scrape).and_return()
      Scrape::Futaba.stub(:scrape).and_return()
      Scrape::Nichan.stub(:scrape).and_return()
      Scrape::Fourchan.stub(:scrape).and_return()
      Scrape::Twitter.stub(:scrape).and_return()

      Scrape::Nico.should_receive(:scrape)
      Scrape::Piapro.should_receive(:scrape)
      Scrape::Pixiv.should_receive(:scrape)
      Scrape::Deviant.should_receive(:scrape)
      Scrape::Futaba.should_receive(:scrape)
      Scrape::Nichan.should_receive(:scrape)
      Scrape::Fourchan.should_receive(:scrape)
      Scrape::Twitter.should_receive(:scrape)

      Scrape.scrape_all()
    end
  end

  describe "is_duplicate method" do
    # 重複していた時にtrueを返す事
    it "should return true when arg url is duplicate" do
      FactoryGirl.create(:image_url)
      Scrape.is_duplicate('http://lohas.nicoseiga.jp/thumb/3804029i').should eq(true)
    end
    it "should return false when arg url is NOT duplicate" do
      FactoryGirl.create(:image_url)
      Scrape.is_duplicate('http://lohas.nicoseiga.jp/thumb/3804020i').should eq(false)
    end
  end

  describe "save_image method" do
    describe "with valid attributes" do
      # 新しいImageレコードを保存すること
      it "should create a new Image model" do
        Image.any_instance.stub(:image_from_url).and_return()
        count = Image.count

        Scrape::save_image('title', 'src_url')
        Image.count.should eq(count+1)
      end

      describe "when the image is not saved" do
        it "should write a log" do
          Image.any_instance.stub(:save).and_return(false)
          Image.any_instance.stub(:image_from_url).and_return()
          Rails.logger.should_receive(:info).with('Image model saving failed.')

          Scrape::save_image('title', 'src_url')
        end
      end

      describe "when DB raise an error during saving the image" do
        it "should not save the image" do
          Image.any_instance.stub(:image_from_url).and_return()
          #Image.any_instance.stub(:save).and_raise SQLite3::SQLException
          Image.any_instance.stub(:save).and_raise Exception

          count = Image.count
          Scrape::save_image('title', 'src_url')
          Image.count.should eq(count)
        end
      end
    end

    describe "with invalid attributes" do
      it "should not save the image" do
        count = Image.count
        Scrape::save_image('title', 'url with no images')
        Image.count.should eq(count)
      end
    end
  end

end