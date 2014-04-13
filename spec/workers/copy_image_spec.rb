#-*- coding: utf-8 -*-
require 'spec_helper'
require "#{Rails.root}/app/workers/copy_image"

describe CopyImage do
  before do
    #IO.any_instance.stub(:puts)
  end

  describe "perform method" do
    it "attaches image file to an image record" do
      #image = FactoryGirl.create(:delivered_image)
      # stubできないのでこちらを使う事に：
      delivered_image = FactoryGirl.create(:delivered_image_no_association)
      image = FactoryGirl.create(:image_file)
      #DeliveredImage.any_instance.should_receive(:save)

      #CopyImage.perform(delivered_image.id, file.data)
      CopyImage.perform(delivered_image.id, image.id)
      delivered = DeliveredImage.find(delivered_image.id)
      puts 'RES'
      puts delivered.data
      puts delivered.data.size
      puts delivered.data.url
      expect(delivered.data.url).not_to eq(nil)
      expect(delivered.data.size).not_to eq(nil)
    end
  end
end