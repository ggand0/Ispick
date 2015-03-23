require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe Scrape::Nichan do
  before do
    allow_any_instance_of(IO).to receive(:puts)             # Surpress console outputs
    allow(Resque).to receive(:enqueue).and_return nil       # Prevent Resque.enqueue method from running
  end

  describe "scrape function" do
    it "calls valid functions" do
      allow(Scrape::Nichan).to receive(:scrape_boards).and_return nil
      expect(Scrape::Nichan).to receive(:scrape_boards).exactly(1).times
      Scrape::Nichan.scrape
    end
  end

  describe "get_boards function" do
    it "returns a valid array" do
      boards = Scrape::Nichan.get_boards
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