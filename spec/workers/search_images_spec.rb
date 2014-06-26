require 'spec_helper'
require "#{Rails.root}/app/workers/search_images"

describe SearchImages do
  before do
    IO.any_instance.stub(:puts)
  end

  describe "perform method" do
    it "attaches image file to an image record" do
      target_word = FactoryGirl.create(:target_word)

      Scrape.stub(:scrape_target_word).and_return nil
      Deliver.stub(:deliver_keyword).and_return nil
      Scrape.should_receive(:scrape_target_word)
      Deliver.should_receive(:deliver_keyword)

      SearchImages.perform target_word.id
    end
  end
end