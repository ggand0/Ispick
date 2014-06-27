require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape_2ch"

describe Scrape::Futaba do
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return nil  # resqueにenqueueしないように
  end

  describe "scrape function" do
    it "calls valid functions" do
      Scrape::Futaba.stub(:scrape_threads).and_return nil
      Scrape::Futaba.should_receive(:scrape_threads).exactly(1).times

      Scrape::Futaba.scrape
    end
  end

  describe "scrape_threads function" do
    it "call valid function" do
      threads = Scrape::Futaba.get_threads

      Scrape.stub(:save_image).and_return nil
      Scrape.should_receive(:save_image).at_least(1).times
      Scrape::Futaba.stub(:get_data).and_return nil
      Scrape::Futaba.should_receive(:get_data).at_least(1).times

      Scrape::Futaba.scrape_threads threads, 1
    end
  end

  describe "get_data function" do
    it "returns valid hash" do
      threads = Scrape::Futaba.get_threads
      post = threads.first.posts.first

      result = Scrape::Futaba.get_data threads.first, post
      expect(result).to be_a(Hash)
    end
  end

end