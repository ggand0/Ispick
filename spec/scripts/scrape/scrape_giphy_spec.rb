require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_giphy"

describe Scrape::Giphy do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  let(:logger) { Logger.new('log/scrape_giphy.log') }
  #let(:response) { IO.read(Rails.root.join('spec', 'fixtures', 'giphy_api_response')) }

  before do
    IO.any_instance.stub(:puts)             # コンソールに出力しないようにしておく
    Resque.stub(:enqueue).and_return nil    # resqueにenqueueしないように
    @client = Scrape::Giphy.get_client
    #@response = JSON.parse(response)['response']
  end

  describe "scrape function" do
    it "calls scrape_using_api function" do
      FactoryGirl.create(:word_with_person)
      Scrape::Giphy.should_receive(:scrape_using_api)
      Scrape::Giphy.scrape(60, true, true)
    end
    it "does not call scrape_using_api function when targetable is NOT enabled" do
      FactoryGirl.create(:target_word_not_enabled)
      Scrape::Giphy.stub(:scrape_using_api).and_return nil
      Scrape::Giphy.should_not_receive(:scrape_using_api)

      Scrape::Giphy.scrape(60, true, true)
    end
    it "skips keywords with nil or empty value" do
      nil_word = TargetWord.new
      nil_word.save!
      Scrape::Giphy.stub(:scrape_using_api).and_return nil
      Scrape::Giphy.should_not_receive(:scrape_using_api)

      Scrape::Giphy.scrape(60, true, true)
    end
  end
  describe "scrape_target_word function" do
    let(:function_response) { { scraped: 0, duplicates: 0, skipped: 0, avg_time: 0 } }

    it "calls scrape_using_api function" do
      target_word = FactoryGirl.create(:word_with_person)

      expect(Scrape::Giphy).to receive(:scrape_using_api).with(target_word, 10, logger, true)
      Scrape::Giphy.stub(:scrape_using_api).and_return(function_response)
      Scrape::Giphy.scrape_target_word(target_word, logger)
    end
  end

  describe "scrape_using_api function" do
    it "calls proper functions" do
      Giphy.stub(:search).and_return([])#::Client.any_instance

      # get_data functionをmockすると何故かcallされなくなるので、save_imageのみ見る
      #Scrape::Giphy.should_receive(:get_data).exactly(5).times

      expect(Giphy).to receive(:search).exactly(1).times
      target_word = FactoryGirl.create(:word_with_person)

      Scrape::Giphy.scrape_using_api(target_word, 5, logger)
    end
  end

  describe "get_data function" do
    it "returns image_data hash" do
      image = FactoryGirl.build(:giphy_api_response)
      obj = Giphy::Gif.new image

      image_data = Scrape::Giphy.get_data(obj)
      expect(image_data).to be_a(Hash)
    end
  end

  describe "get_tags function" do
    it "returns an array of tags" do
      tags = Scrape::Giphy.get_tags(['Madoka'])
      expect(tags).to be_an(Array)
      expect(tags.first.name).to eql('Madoka')
    end
    it "uses existing tags if tags are duplicate" do
      image = FactoryGirl.create(:image)
      tag = FactoryGirl.create(:tag)
      image.tags << tag

      tags = Scrape::Giphy.get_tags(['鹿目まどか'])
      expect(tags.first.images.first.id).to eql(tag.images.first.id)
    end
  end

  describe "get_client function" do
    it "returns Giphy client" do
      client = Scrape::Giphy.get_client
      client.class.should eq(Class)
    end
  end

end