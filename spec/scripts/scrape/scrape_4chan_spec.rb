require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape_4chan"

describe Scrape::Fourchan do
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return nil  # resqueにenqueueしないように
  end

  describe "scrape function" do
    it "calls valid functions" do
      Scrape.stub(:save_image).and_return nil
      Scrape.should_receive(:save_image).at_least(1).times

      Scrape::Fourchan.stub(:get_thread_id_list).and_return nil
      Scrape::Fourchan.stub(:get_thread_post_list).and_return nil
      Scrape::Fourchan.stub(:get_image_url_list).and_return([{ title: 'test', src_url: 'example.com', is_large: false }])
      Scrape::Fourchan.should_receive(:get_thread_id_list).exactly(1).times
      Scrape::Fourchan.should_receive(:get_thread_post_list).exactly(1).times
      Scrape::Fourchan.should_receive(:get_image_url_list).exactly(1).times

      Scrape::Fourchan.scrape
    end
  end

  describe "get_board_list function" do
    it "returns a valid hash" do
      result = Scrape::Fourchan.get_board_list
      expect(result).to be_a(Hash)
    end
  end

  describe "get_thread_id_list function" do
    it "returns a valid array" do
      result = Scrape::Fourchan.get_thread_id_list 'c', 1
      expect(result).to be_an(Array)
    end
  end

  describe "get_thread_post_list function" do
    it "returns a valid array" do
      puts thread_id_list = Scrape::Fourchan.get_thread_id_list('c', 5)

      result = Scrape::Fourchan.get_thread_post_list 'c', thread_id_list
      expect(result).to be_an(Array)
    end
  end

  describe "get_image_url_list function" do
    it "returns a valid array" do
      thread_id_list = Scrape::Fourchan.get_thread_id_list('c', 1)
      thread_post_list = Scrape::Fourchan.get_thread_post_list 'c', thread_id_list

      result = Scrape::Fourchan.get_image_url_list 'c', thread_post_list
    end
  end

  describe "get_posted_at function" do
    it "parses string to valid datetime" do
      time_string = '03\/24\/14(Mon)16:09'
      result = Scrape::Fourchan.get_posted_at time_string
      expect(result).to eql(Time.mktime(2014, 3, 24, 16, 9).in_time_zone('Asia/Tokyo').utc)
    end
  end

  describe "get_image_name function" do
    it "returns a string" do
      url = 'www.example.com'
      result = Scrape::Fourchan.get_image_name url
      expect(result).to be_a(String)
    end
  end

end