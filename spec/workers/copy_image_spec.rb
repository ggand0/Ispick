#-*- coding: utf-8 -*-
require 'spec_helper'
require "#{Rails.root}/app/workers/copy_image"

describe CopyImage do
  before do
    IO.any_instance.stub(:puts)
  end

  describe "perform method" do
    it "attaches image file to an image record" do
      image = FactoryGirl.create(:image)
      file = FactoryGirl.create(:image_file)
      Image.any_instance.should_receive(:save!)

      CopyImage.perform(image.id, file.data)
      expect(Image.find(image.id).data).not_to eq(nil)
    end
  end
end