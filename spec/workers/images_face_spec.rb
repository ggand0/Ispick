require 'spec_helper'
require "#{Rails.root}/app/workers/images_face"
require "#{Rails.root}/app/services/target_images_service"

describe ImageFace do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_file) }

  describe "perform method" do
    it "should create a new Feature model" do
      image = Image.create! valid_attributes
      face = ImageFace.new
      TargetImagesService.any_instance.stub(:prefer).and_return({ time: 0, result: '[]' })

      count = Feature.count
      ImageFace::perform(image.id)

      Feature.count.should eq(count+1)
      image.feature.should eq(Feature.first)
    end
  end
end