# [Not Used] on 25/01/15

require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

=begin
describe Scrape::Giphy, :broken => true do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  let(:logger) { Logger.new('log/scrape_giphy.log') }
  #let(:response) { IO.read(Rails.root.join('spec', 'fixtures', 'giphy_api_response')) }

  before do
    allow_any_instance_of(IO).to receive(:puts)
    allow(Resque).to receive(:enqueue).and_return nil
    #@response = JSON.parse(response)['response']

    @giphy_client = Scrape::Giphy.get_client
    @client = Scrape::Giphy.new(nil, 10)
  end

  describe "scrape method" do
    it "calls scrape_target_words function" do
      FactoryGirl.create(:person_madoka)
      allow(@client).to receive(:scrape_target_words).and_return nil
      expect(@client).to receive(:scrape_target_words)

      @client.scrape(60)
    end
  end

  describe "scrape_target_word function" do
    let(:function_response) { { scraped: 0, duplicates: 0, skipped: 0, avg_time: 0 } }

    it "calls scrape_using_api function" do
      target_word = FactoryGirl.create(:word_with_person)

      expect(@client).to receive(:scrape_using_api).with(target_word, 1, true)
      allow(@client).to receive(:scrape_using_api).and_return(function_response)
      @client.scrape_target_word(1, target_word)
    end
  end

  describe "scrape_using_api function" do
    it "calls proper functions" do
      allow(Giphy).to receive(:search).and_return([])#::Client.any_instance

      # get_data functionをmockすると何故かcallされなくなるので、save_imageのみ見る
      #Scrape::Giphy.should_receive(:get_data).exactly(5).times

      expect(Giphy).to receive(:search).exactly(1).times
      target_word = FactoryGirl.create(:word_with_person)

      @client.scrape_using_api(target_word)
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

  describe "get_client function" do
    it "returns Giphy client" do
      client = Scrape::Giphy.get_client
      expect(client.class).to eq(Class)
    end
  end

end
=end