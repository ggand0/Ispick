require 'spec_helper'
require "#{Rails.root}/app/workers/target_images_face"
require "#{Rails.root}/app/services/target_images_service"

describe TargetFace do
  let(:valid_attributes) { FactoryGirl.attributes_for(:target_image) }

  before do
    allow_any_instance_of(IO).to receive(:puts)
  end

  describe "get_categories function" do
    it "returns hash of image_net categories" do
      target_image = TargetImage.create! valid_attributes
      hash = TargetFace.get_categories target_image

      expect(hash).to be_a(Hash)
      expect(hash.keys.count).to eq(4096)
      expect(hash.values.count).to eq(4096)
    end
  end

  describe "perform method" do
    it "creates a new Feature model" do
      target_image = TargetImage.create! valid_attributes
      face = TargetFace.new
      allow_any_instance_of(TargetImagesService).to receive(:prefer).and_return({ time: 0, result: '[]' })

      count = Feature.count
      TargetFace::perform(target_image.id)

      expect(Feature.count).to eq(count+1)
      expect(target_image.feature).to eq(Feature.first)
    end
  end
end