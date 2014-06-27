require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe TargetWord do
  describe "after_create callback" do
    it "enqueues a resque job" do
      Resque.stub(:enqueue).and_return nil
      Resque.should_receive(:enqueue)
      #TargetWord.any_instance.stub(:search_keyword).and_return
      #TargetWord.any_instance.should_receive(:search_keyword)

      FactoryGirl.create(:word_with_run_callback)
    end
  end

  describe "validation uniqueness" do
    it "validates uniqueness of word attribute properly" do
      Resque.stub(:enqueue).and_return nil
      FactoryGirl.create(:target_word_with_user)
      FactoryGirl.create(:target_word_with_user)
    end
  end
end
