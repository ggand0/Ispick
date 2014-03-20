require 'spec_helper'
require "#{Rails.root}/script/deliver/deliver"

describe "Deliver" do
  describe "delete_excessed_records" do
    it "delete images properly" do
      FactoryGirl.create(:user_with_delivered_images, images_count: 2)
      images = User.first.delivered_images
      size = images.first.data.size + 1024
      Deliver.delete_excessed_records(User.first.delivered_images, size)
      expect(User.first.delivered_images.count).to eq(1)
    end
  end
end