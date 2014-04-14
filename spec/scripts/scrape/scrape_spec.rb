require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe Scrape do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    IO.any_instance.stub(:puts)
    # resqueにenqueueしないように
    Resque.stub(:enqueue).and_return
  end

  describe "scrape_all method" do
    it "runs all scraping script" do
      Scrape::Nico.stub(:scrape).and_return()
      Scrape::Piapro.stub(:scrape).and_return()
      #Scrape::Pixiv.stub(:scrape).and_return()
      Scrape::Deviant.stub(:scrape).and_return()
      Scrape::Futaba.stub(:scrape).and_return()
      Scrape::Nichan.stub(:scrape).and_return()
      Scrape::Fourchan.stub(:scrape).and_return()
      Scrape::Twitter.stub(:scrape).and_return()
      Scrape::Tumblr.stub(:scrape).and_return()

      Scrape::Nico.should_receive(:scrape)
      Scrape::Piapro.should_receive(:scrape)
      #Scrape::Pixiv.should_receive(:scrape)
      Scrape::Deviant.should_receive(:scrape)
      #Scrape::Futaba.should_receive(:scrape)
      #Scrape::Nichan.should_receive(:scrape)
      #Scrape::Fourchan.should_receive(:scrape)
      Scrape::Twitter.should_receive(:scrape)
      Scrape::Tumblr.should_receive(:scrape)

      Scrape.scrape_all()
    end
  end

  describe "scrape sub function method" do
    it "runs all scraping script in _5min function" do
      Scrape::Nico.stub(:scrape).and_return()
      Scrape::Futaba.stub(:scrape).and_return()
      Scrape::Nico.should_receive(:scrape)
      #Scrape::Futaba.should_receive(:scrape)
      Scrape.scrape_5min()
    end
    it "runs all scraping script in _15min function" do
      Scrape::Piapro.stub(:scrape).and_return()
      Scrape::Nichan.stub(:scrape).and_return()
      Scrape::Twitter.stub(:scrape).and_return()
      Scrape::Tumblr.stub(:scrape).and_return()
      Scrape::Piapro.should_receive(:scrape)
      #Scrape::Nichan.should_receive(:scrape)
      Scrape::Twitter.should_receive(:scrape)
      Scrape::Tumblr.should_receive(:scrape)
      Scrape.scrape_15min()
    end
    it "runs all scraping script in _30min function" do
      Scrape::Fourchan.stub(:scrape).and_return()
      #Scrape::Fourchan.should_receive(:scrape)
      Scrape.scrape_30min()
    end
    it "runs all scraping script in _60min function" do
      #Scrape::Pixiv.stub(:scrape).and_return()
      Scrape::Deviant.stub(:scrape).and_return()
      #Scrape::Pixiv.should_receive(:scrape)
      Scrape::Deviant.should_receive(:scrape)
      Scrape.scrape_60min()
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
        Image.any_instance.stub(:image_from_url).and_return()
        count = Image.count

        Scrape::save_image({ title: 'title', src_url: 'src_url' })
        Image.count.should eq(count+1)
      end

      describe "when the image is not saved" do
        it "should write a log" do
          Image.any_instance.stub(:save).and_return(false)
          Image.any_instance.stub(:image_from_url).and_return()
          #Rails.logger.should_receive(:info).with('Image model saving failed.')

          Scrape::save_image({ title: 'title', src_url: 'src_url' })
        end
      end

      describe "when DB raise an error during saving the image" do
        it "should not save the image" do
          Image.any_instance.stub(:image_from_url).and_return()
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