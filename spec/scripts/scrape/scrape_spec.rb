require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe Scrape do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  let(:logger) { Logger.new('log/scrape_cron.log') }
  before do
    #IO.any_instance.stub(:puts)
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
      FactoryGirl.create(:image_min)
      Scrape.is_duplicate('http://lohas.nicoseiga.jp/thumb/3804029i').should eq(true)
    end
    it "should return false when arg url is NOT duplicate" do
      FactoryGirl.create(:image_min)
      Scrape.is_duplicate('http://lohas.nicoseiga.jp/thumb/3804020i').should eq(false)
    end
  end

  describe "get_query function" do
    it "returns proper string when target_word has a person model" do
      target_word = FactoryGirl.create(:word_with_person)
      result = Scrape.get_query target_word

      expect(result).to eq('鹿目まどか')
    end
    it "returns proper string when target_word doesn't have a person model" do
      target_word = FactoryGirl.create(:target_word)
      result = Scrape.get_query target_word

      expect(result).to eq('鹿目 まどか（かなめ まどか）1')
    end
  end

  describe "save_image method" do
    describe "with valid attributes" do
      it "should create a new Image model" do
        Image.any_instance.stub(:image_from_url).and_return nil
        count = Image.count

        Scrape::save_image({ title: 'title', src_url: 'src_url' }, logger)
        Image.count.should eq(count+1)
      end

      describe "when the image is not saved" do
        it "should write a log" do
          Image.any_instance.stub(:save).and_return(false)
          Image.any_instance.stub(:image_from_url).and_return nil
          #Rails.logger.should_receive(:info).with('Image model saving failed.')

          Scrape::save_image({ title: 'title', src_url: 'src_url' }, logger)
        end
      end

      describe "when it cannot save the image" do
        it "returns nil" do
          Image.any_instance.stub(:save).and_return(false)

          count = Image.count
          result = Scrape::save_image({ title: 'title', src_url: 'src_url' }, logger)
          expect(result).to eq(nil)
          expect(Image.count).to eq(count)
        end
      end
    end

    describe "with invalid attributes" do
      it "should not save an invalid image when validation param is true" do
        image = FactoryGirl.create(:image)
        count = Image.count
        Scrape::save_image({ title: 'test', src_url: 'test1@example.com' }, logger, [], true)
        Image.count.should eq(count)
      end

      it "should ignore a duplicate image" do
        image = FactoryGirl.create(:image_min)
        count = Image.count

        Scrape::save_image({ title: 'title', src_url: image.src_url }, logger)
        Image.count.should eq(count)
      end
    end
  end

end