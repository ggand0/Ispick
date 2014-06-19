require 'spec_helper'
require "#{Rails.root}/script/deliver/deliver"
require "#{Rails.root}/script/deliver/deliver_words"
require "#{Rails.root}/script/deliver/deliver_images"
require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

describe "Deliver::Images" do
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return nil # resqueのjobを実際に実行しないように
  end

  describe "deliver_from_image function" do
    it "deliver properly" do
    end
  end

  describe "close_image function" do
    it "returns images that have almost equal featuress" do
      f_image = FactoryGirl.create(:feature_madoka1)
      f_target_image = FactoryGirl.create(:feature_madoka)
      image = Image.find(f_image.featurable_id)
      target_image = TargetImage.find(f_target_image.featurable_id)

      puts res = Deliver::Images.close_image(image, target_image, 80)
    end
  end

  describe "get_images function" do

  end
end