require 'spec_helper'
require "#{Rails.root}/app/workers/detect_illust"

describe DetectIllust do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_file) }

  before do
    #IO.any_instance.stub(:puts)
  end

  describe "perform method" do
    it "should create a new Feature model" do
      image = Image.create! valid_attributes

      detect = DetectIllust.new
      DetectIllust::perform(image.id)

      image.is_illust.should eq(true)
    end
  end
end