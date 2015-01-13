require 'spec_helper'
require "#{Rails.root}/app/workers/search_images"

describe SearchImages do
  before do
    allow_any_instance_of(IO).to receive(:puts)             # Suppress console outputs
  end

  describe "perform method" do
    it "attaches image file to an image record" do
      target_word = FactoryGirl.create(:target_word)
      user = FactoryGirl.create(:user_with_callbacks)

      allow(Scrape).to receive(:scrape_target_word).and_return nil
      expect(Scrape).to receive(:scrape_target_word).with(user.id, target_word, SearchImages.logger)

      SearchImages.perform(user.id, target_word.id)
    end
  end
end