require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape_4chan"

describe Scrape::Fourchan do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return  # resqueにenqueueしないように
  end


  describe "scrape function" do
    it "calls valid functions" do
      Scrape::Fourchan.stub(:get_thread_id_list).and_return()
      Scrape::Fourchan.stub(:get_thread_post_list).and_return()
      Scrape::Fourchan.stub(:get_image_url_list).and_return()
      Scrape::Fourchan.should_receive(:get_thread_id_list).exactly(1).times
      Scrape::Fourchan.should_receive(:get_thread_post_list).exactly(1).times
      Scrape::Fourchan.should_receive(:get_image_url_list).exactly(1).times

      Scrape::Fourchan.scrape
    end
  end
end