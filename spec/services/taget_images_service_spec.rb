require 'spec_helper'
require "#{Rails.root}/app/services/target_images_service"
include ActionDispatch::TestProcess

describe TargetImagesService do
  let(:valid_attributes) {{
    title: "MyString",
    data: fixture_file_upload('files/madoka.png')
  }}

  describe "prefer method" do
    #specify "returns list of images" do
    it "returns list of images" do
      target_image = TargetImage.create! valid_attributes

      service = TargetImagesService.new
      list = service.prefer target_image
      list.should be_an(Hash)
    end
  end
end