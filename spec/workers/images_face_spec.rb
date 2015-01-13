require 'spec_helper'
require "#{Rails.root}/app/workers/images_face"
require "#{Rails.root}/app/services/target_images_service"

describe ImageFace do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_file) }

  before do
    allow_any_instance_of(IO).to receive(:puts)
  end

  describe "get_categories function" do
    it "returns hash of image_net categories" do
      image = Image.create! valid_attributes
      hash = ImageFace.get_categories image

      expect(hash).to be_a(Hash)
      expect(hash.keys.count).to eq(4096)
      expect(hash.values.count).to eq(4096)
    end
  end

  describe "perform method" do
    it "should create a new Feature model" do
      image = Image.create! valid_attributes
      face = ImageFace.new
      allow_any_instance_of(TargetImagesService).to receive(:prefer).and_return({ time: 0, result: '[]' })

      count = Feature.count
      ImageFace::perform(image.class.name, image.id)

      expect(Feature.count).to eq(count+1)
      expect(image.feature).to eq(Feature.first)
    end
  end
end