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

  describe "get_preferred_images" do
    it "returns a valid data" do
      face_feature = FactoryGirl.create(:feature_madoka)
      target_image = TargetImage.find(face_feature.featurable_id)

      service = TargetImagesService.new
      result = service.get_preferred_images(target_image)
      result.should be_a(Hash)
      result[:images].should be_an(Array)
      result[:target_colors].should be_a(Hash)
    end

    it "returns a precise preferred image" do
      face_feature = FactoryGirl.create(:feature_madoka)
      target_image = TargetImage.find(face_feature.featurable_id)
      # 似てるImageが存在している場合
      FactoryGirl.create(:feature_madoka1)

      service = TargetImagesService.new
      result = service.get_preferred_images(target_image)

      # そのImageが推薦される
      result[:images].length.should eq(1)
    end
  end

end