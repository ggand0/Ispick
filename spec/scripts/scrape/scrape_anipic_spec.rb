require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_anipic"

describe Scrape::Anipic do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  let(:response) { IO.read(Rails.root.join('spec', 'fixtures', 'tumblr_api_response')) }
  before do
    IO.any_instance.stub(:puts)             # コンソールに出力しないようにしておく
    Resque.stub(:enqueue).and_return nil    # resqueにenqueueしないように
    @client = Scrape::Anipic.new(nil, 5)
    #Rails.stub_chain(:logger, :debug).and_return(logger_mock)
    @response = JSON.parse(response)['response']
    @logger = Logger.new('log/scrape_tumblr_cron.log')
  end

  describe "scrape method" do
    it "calls scrape_target_words function" do
      FactoryGirl.create(:person_madoka)
      @client.stub(:scrape_target_words).and_return nil
      expect(@client).to receive(:scrape_target_words)

      @client.scrape(60)
    end
  end

  describe "get_time class method" do
    it "returns a valid time string" do
      time = '  8/14/14, 2:52 PM'
      time = Scrape::Anipic.get_time(time)

      expect(time).to eq('2014/8/14/14:52')

      time = '8/16/14, 5:31 PM'
      time = Scrape::Anipic.get_time(time)

      expect(time).to eq('2014/8/16/17:31')

      time = '8/16/14, 12:31 PM'
      time = Scrape::Anipic.get_time(time)

      expect(time).to eq('2014/8/16/0:31')
    end
  end

end