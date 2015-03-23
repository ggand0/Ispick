require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe TargetWord do
  describe "validation uniqueness" do
    it "validates uniqueness of word attribute properly" do
      allow(Resque).to receive(:enqueue).and_return nil       # Prevent Resque.enqueue method from running

      TargetWord.create(name: 'Madoka Kaname')
      expect(TargetWord.new(name: 'Madoka Kaname').save).to eq(false)
    end
  end
end
