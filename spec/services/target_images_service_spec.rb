#require 'spec_helper'
require "#{Rails.root}/app/controllers/target_images_service"

describe TargetImagesService do
  describe "#prefer" do
    it "returns list of images" do
      service = TargetImagesService.new
      puts service
      list = service.prefer
      puts list
      list.length.should > 0
    end
  end
end