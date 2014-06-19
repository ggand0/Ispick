require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape_2ch"

describe Scrape::Nichan do
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return  # resqueにenqueueしないように
  end

  describe "scrape function" do
    it "calls valid functions" do
      Scrape::Nichan.stub(:scrape_boards).and_return
      Scrape::Nichan.should_receive(:scrape_boards).exactly(1).times

      Scrape::Nichan.scrape
    end
  end

  describe "get_boards function" do
    it "returns a valid array" do
      puts boards = Scrape::Nichan.get_boards
      expect(boards).to be_an(Array)
    end
  end

  describe "scrape_posts function" do
    it "calls valid functions" do
      thread = Scrape::Nichan.get_boards.first.threads.first

    end
  end

  describe "get_posted_at function" do
    it "parses a string to a valid datetime value" do

    end
  end

end