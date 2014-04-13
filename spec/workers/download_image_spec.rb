#-*- coding: utf-8 -*-
require 'spec_helper'
require "#{Rails.root}/app/workers/download_image"

describe DownloadImage do
  before do
    IO.any_instance.stub(:puts)
  end

  describe "perform method" do
    it "attaches image file to an image record" do
      url = 'http://goo.gl/4b7UUc'
      image = FactoryGirl.create(:image)
      Image.any_instance.should_receive(:save!)

      DownloadImage.perform(image.id, url)
    end
  end
end