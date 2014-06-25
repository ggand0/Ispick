require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe Scrape do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return nil  # resqueにenqueueしないように
  end

  describe "scrape_all method" do
    it "runs all scraping script" do
      FactoryGirl.create(:target_word)
      Scrape.stub(:scrape_keyword).and_return nil
      Scrape.should_receive(:scrape_keyword).exactly(1).times

      Scrape.scrape_all
    end
  end

  describe "is_duplicate method" do
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
      it "should create a new Image model" do
        Image.any_instance.stub(:image_from_url).and_return nil
        count = Image.count

        Scrape::save_image({ title: 'title', src_url: 'src_url' })
        Image.count.should eq(count+1)
      end

      describe "when the image is not saved" do
        it "should write a log" do
          Image.any_instance.stub(:save).and_return(false)
          Image.any_instance.stub(:image_from_url).and_return nil
          #Rails.logger.should_receive(:info).with('Image model saving failed.')

          Scrape::save_image({ title: 'title', src_url: 'src_url' })
        end
      end

      describe "when DB raise an error during saving the image" do
        it "should not save the image" do
          Image.any_instance.stub(:image_from_url).and_return nil
          Image.any_instance.stub(:save).and_raise Exception

          count = Image.count
          Scrape::save_image({ title: 'title', src_url: 'src_url' })
          Image.count.should eq(count)
        end
      end
    end

    describe "with invalid attributes" do
      it "should not save the image with validation" do
        count = Image.count
        Scrape::save_image({ title: 'title', src_url: 'url with no images' }, nil, true)
        Image.count.should eq(count)
      end

      it "should ignore duplicate image" do
        image = FactoryGirl.create(:image_url)
        count = Image.count

        Scrape::save_image({ title: 'title', src_url: image.src_url })
        Image.count.should eq(count)
      end
    end
  end

end