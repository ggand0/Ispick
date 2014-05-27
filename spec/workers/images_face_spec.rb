require 'spec_helper'
require "#{Rails.root}/app/workers/images_face"
require "#{Rails.root}/app/services/target_images_service"

describe ImageFace do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_file) }

  before do
    IO.any_instance.stub(:puts)
  end

  describe "get_categories function" do
    it "returns hash of image_net categories" do
      image = Image.create! valid_attributes
      hash = ImageFace.get_categories image
      expect(hash).to be_a(Hash)
      expect(hash['butcher shop']).to eq(0.141260)
    end
  end

  describe "perform method" do
    it "should create a new Feature model" do
      image = Image.create! valid_attributes
      face = ImageFace.new
      TargetImagesService.any_instance.stub(:prefer).and_return({ time: 0, result: '[]' })

      count = Feature.count
      ImageFace::perform(image.class.name, image.id)

      Feature.count.should eq(count+1)
      image.feature.should eq(Feature.first)
    end
  end
end