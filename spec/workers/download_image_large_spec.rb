#-*- coding: utf-8 -*-
require 'spec_helper'
require "#{Rails.root}/app/workers/download_image_large"

describe DownloadImageLarge do
  before do
    allow_any_instance_of(IO).to receive(:puts)             # Suppress console outputs
    @url = 'http://goo.gl/4b7UUc'
  end

  describe "perform method" do
    it "attaches image file to an image record" do
      image = FactoryGirl.create(:image)
      expect_any_instance_of(Image).to receive(:save!)

      DownloadImageLarge.perform(image.class.name, image.id, @url)
    end

    it "destroys the image when it has duplicate md5_checksum" do
      image1 = FactoryGirl.create(:image)
      image2 = FactoryGirl.create(:image)

      DownloadImageLarge.perform(image1.class.name, image1.id, @url)
      expect(Image).to receive(:destroy)
      DownloadImageLarge.perform(image2.class.name, image2.id, @url)
    end

    it "writes a log when it crashes" do
      image = FactoryGirl.create(:image)
      allow_any_instance_of(Image).to receive(:image_from_url).and_raise
      expect(Rails.logger).to receive(:error).exactly(1).times

      DownloadImageLarge.perform(image.class.name, image.id, @url)
    end
  end

end