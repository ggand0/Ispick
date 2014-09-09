require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe TargetWord do
  describe "validation uniqueness" do
    it "validates uniqueness of word attribute properly" do
      Resque.stub(:enqueue).and_return nil

      TargetWord.create(word: 'Madoka Kaname')
      expect(TargetWord.new(word: 'Madoka Kaname').save).to eq(false)
    end
  end
end
