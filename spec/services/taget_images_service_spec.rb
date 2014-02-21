require 'spec_helper'
#require 'rubygems'
#require 'rspec'
require "#{Rails.root}/app/services/target_images_service"

describe TargetImagesService do
  describe "prefer method" do
    #specify "returns list of images" do
    it "returns list of images" do
      service = TargetImagesService.new
      list = service.prefer
      #list.should be_a(Array)
      list.length.should > 0
    end
  end
end