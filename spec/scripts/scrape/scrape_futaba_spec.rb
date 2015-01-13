require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe Scrape::Futaba do
  before do
    allow_any_instance_of(IO).to receive(:puts)
    allow(Resque).to receive(:enqueue).and_return nil  # resqueにenqueueしないように
  end

  describe "scrape function" do
    it "calls valid functions" do
      allow(Scrape::Futaba).to receive(:scrape_threads).and_return nil
      expect(Scrape::Futaba).to receive(:scrape_threads).exactly(1).times

      Scrape::Futaba.scrape
    end
  end

  describe "scrape_threads function" do
    it "call valid function" do
      threads = Scrape::Futaba.get_threads

      allow(Scrape).to receive(:save_image).and_return nil
      expect(Scrape).to receive(:save_image).at_least(1).times
      allow(Scrape::Futaba).to receive(:get_data).and_return nil
      expect(Scrape::Futaba).to receive(:get_data).at_least(1).times

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