require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe TargetWord do
  describe "validation uniqueness" do
    it "validates uniqueness of word attribute properly" do
      Resque.stub(:enqueue).and_return nil

      TargetWord.create(name: 'Madoka Kaname')
      expect(TargetWord.new(name: 'Madoka Kaname').save).to eq(false)
    end
  end
end
