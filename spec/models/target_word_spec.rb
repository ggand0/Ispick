require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe TargetWord do
  describe "after_create callback" do
    it "calls the scrape module function" do
      Scrape.should_receive(:scrape_keyword).with('鹿目まどか')

      #target_word = FactoryGirl.create(:person_madoka)
      target_word = FactoryGirl.build(:target_word)
      person = FactoryGirl.create(:person)
      target_word.person = person
      target_word.save!
    end
  end
end
