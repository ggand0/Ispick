require 'spec_helper'
require "#{Rails.root}/script/scrap"

describe Scrap do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    IO.any_instance.stub(:puts)
  end

  describe "scrap_all method" do
    it "runs all scraping script" do
      Scrap::Nico.stub(:scrap).and_return()
      Scrap::Piapro.stub(:scrap).and_return()
      Scrap::Pixiv.stub(:scrap).and_return()
      Scrap::Deviant.stub(:scrap).and_return()

      Scrap::Nico.should_receive(:scrap)
      Scrap::Piapro.should_receive(:scrap)
      Scrap::Pixiv.should_receive(:scrap)
      Scrap::Deviant.should_receive(:scrap)

      Scrap.scrap_all()
    end
  end

  describe "save_image method" do
    describe "with valid attributes" do
      it "should create a new Image model" do
        Image.any_instance.stub(:image_from_url).and_return()
        count = Image.count

        Scrap::save_image('title', 'src_url')
        Image.count.should eq(count+1)
      end

      describe "when the image is not saved" do
        it "should write a log" do
          Image.any_instance.stub(:save).and_return(false)
          Image.any_instance.stub(:image_from_url).and_return()
          Rails.logger.should_receive(:info).with('Image model saving failed.')

          Scrap::save_image('title', 'src_url')
        end
      end

      describe "when DB raise an error during saving the image" do
        it "should not save the image" do
          Image.any_instance.stub(:image_from_url).and_return()
          Image.any_instance.stub(:save).and_raise SQLite3::SQLException
          #Rails.logger.should_receive(:info).with('Image model saving failed.')

          count = Image.count
          Scrap::save_image('title', 'src_url')
          Image.count.should eq(count)
        end
      end
    end
    describe "with invalid attributes" do
      it "should not save the image" do
        count = Image.count
        Scrap::save_image('title', 'url with no images')
        Image.count.should eq(count)
      end
    end
  end
end