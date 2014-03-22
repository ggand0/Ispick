require 'spec_helper'
require "#{Rails.root}/script/deliver/deliver"
require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

describe "Deliver" do
  describe "delete_excessed_records" do
    before do
      IO.any_instance.stub(:puts)
    end
    it "delete images properly" do
      FactoryGirl.create(:user_with_delivered_images, images_count: 2)
      images = User.first.delivered_images
      size = ApplicationHelper.bytes_to_megabytes(images.first.data.size) + 1
      Deliver.delete_excessed_records(User.first.delivered_images, size)
      expect(User.first.delivered_images.count).to eq(1)
    end
  end
end