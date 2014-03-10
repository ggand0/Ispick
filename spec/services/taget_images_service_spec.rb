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
    # 正しい型の値を返すこと
    it "returns a valid data" do
      face_feature = FactoryGirl.create(:feature_madoka)
      target_image = TargetImage.find(face_feature.featurable_id)

      service = TargetImagesService.new
      result = service.get_preferred_images(target_image)
      result.should be_a(Hash)
      result[:images].should be_an(Array)
      result[:target_colors].should be_a(Hash)
    end

    describe "with single face" do
      # 似た髪色を持つイラストを推薦すること
      it "returns a precise preferred image" do
        face_feature = FactoryGirl.create(:feature_madoka)
        target_image = TargetImage.find(face_feature.featurable_id)

        # 似てるImageが存在している場合
        FactoryGirl.create(:feature_madoka1)
        service = TargetImagesService.new

        # そのImageが推薦される
        result = service.get_preferred_images(target_image)
        result[:images].length.should eq(1)
      end
    end

    describe "with multiple faces" do
      # 全ての顔に対して似た特徴量を持つイラストを推薦すること
      it "returns precise preferred images to ALL target_images" do
        FactoryGirl.create(:feature_madoka_multi)
        FactoryGirl.create(:feature_homura_multi)
        face_feature = FactoryGirl.create(:feature_madoka_homura)
        target_image = TargetImage.find(face_feature.featurable_id)
        service = TargetImagesService.new

        # 両方推薦される
        result = service.get_preferred_images(target_image)
        result[:images].length.should eq(2)
      end
    end

  end

end