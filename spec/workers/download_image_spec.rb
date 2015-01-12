#-*- coding: utf-8 -*-
require 'spec_helper'
require "#{Rails.root}/app/workers/download_image"

describe DownloadImage do
  before do
    allow_any_instance_of(IO).to receive(:puts)             # Suppress console outputs
    allow(Resque).to receive(:enqueue).and_return nil       # Prevent Resque.enqueue method
    @url = 'http://goo.gl/4b7UUc'
  end

  describe "perform method" do
    it "attaches image file to an image record" do
      image = FactoryGirl.create(:image)
      Image.any_instance.should_receive(:save!)

      DownloadImage.perform(image.id, 'Image', @url)
    end

    it "destroys the image when it has duplicate md5_checksum" do
      image1 = FactoryGirl.create(:image)
      image2 = FactoryGirl.create(:image)

      puts image1.inspect
      puts image2.inspect
      puts '================================='
      DownloadImage.perform(image1.id, 'Image', @url)
      puts image1.inspect
      Image.should_receive(:destroy)
      DownloadImage.perform(image2.id, 'Image', @url)
      puts image2.inspect
    end

    it "writes a line in the log when it crashes(but be rescued)" do
      image = FactoryGirl.create(:image)
      Image.any_instance.stub(:image_from_url).and_raise

      expect(DownloadImage.logger).to receive(:error).exactly(1).times

      DownloadImage.perform(image.id, 'Image', @url)
    end
  end

end