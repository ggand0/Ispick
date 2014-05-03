require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe TargetWord do
  describe "after_create callback" do
    it "enqueues a resque job" do
      Resque.stub(:enqueue).and_return
      TargetWord.stub(:search_keyword).and_return
      TargetWord.any_instance.should_receive(:search_keyword)

      FactoryGirl.create(:target_words)
    end
  end

  describe "validation uniqueness" do
    it "validates uniqueness of word attribute properly" do
      Resque.stub(:enqueue).and_return
      FactoryGirl.create(:target_word_with_user)
      FactoryGirl.create(:target_word_with_user)
    end
  end
end
