require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe TargetWord do
  describe "after_create callback" do
    it "enqueues a resque job" do
      Resque.should_receive(:enqueue).exactly(1).times
      #Resque.any_instance.should_receive(:enqueue).exactly(1).times
      Resque.stub(:enqueue).and_return

      target_word = FactoryGirl.build(:target_word_with_callback)
      person = FactoryGirl.create(:person)
      target_word.person = person
      target_word.save!
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
