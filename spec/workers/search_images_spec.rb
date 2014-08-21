require 'spec_helper'
require "#{Rails.root}/app/workers/search_images"

describe SearchImages do
  before do
    IO.any_instance.stub(:puts)
  end

  describe "perform method" do
    it "attaches image file to an image record" do
      target_word = FactoryGirl.create(:target_word)
      user = FactoryGirl.create(:user_with_callbacks)

      Scrape.stub(:scrape_target_word).and_return nil
      #Deliver.stub(:deliver_keyword).and_return nil
      #expect(Deliver).to receive(:deliver_keyword).with(user.id, target_word.id, SearchImages.logger)
      expect(Scrape).to receive(:scrape_target_word).with(user.id, target_word, SearchImages.logger)

      SearchImages.perform(user.id, target_word.id)
    end
  end
end