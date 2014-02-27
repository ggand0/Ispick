require 'spec_helper'
require "#{Rails.root}/app/services/target_images_service"
include ActionDispatch::TestProcess

describe TargetImagesService do
  let(:valid_attributes) { FactoryGirl.attributes_for(:target_image) }

  describe "get_face_feature method" do
    it "returns face feature array of a image" do
      target_image = TargetImage.create! valid_attributes
      AnimeFace.stub(:detect).and_return(['a json array'])

      service = TargetImagesService.new
      service.get_face_feature(target_image.data.path).should be_an(Array)
    end
  end

  describe "prefer method" do
    it "returns list of images" do
      target_image = TargetImage.create! valid_attributes
      AnimeFace.stub(:detect).and_return(['a json array'])

      service = TargetImagesService.new
      list = service.prefer target_image
      list.should be_an(Hash)
    end
  end
end