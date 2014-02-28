require 'spec_helper'
require "#{Rails.root}/app/workers/target_images_face"
require "#{Rails.root}/app/services/target_images_service"

describe Face do
  let(:valid_attributes) { FactoryGirl.attributes_for(:target_image) }

  describe "perform method" do
    it "should create a new Feature model" do
      target_image = TargetImage.create! valid_attributes
      face = Face.new
      TargetImagesService.any_instance.stub(:prefer).and_return({ time: 0, result: '[]' })

      count = Feature.count
      Face::perform(target_image.id)

      Feature.count.should eq(count+1)
      target_image.feature.should eq(Feature.first)
    end
  end
end