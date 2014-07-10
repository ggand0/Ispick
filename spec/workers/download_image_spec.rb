#-*- coding: utf-8 -*-
require 'spec_helper'
require "#{Rails.root}/app/workers/download_image"

describe DownloadImage do
  before do
    IO.any_instance.stub(:puts)
    @url = 'http://goo.gl/4b7UUc'
  end

  describe "perform method" do
    it "attaches image file to an image record" do
      image = FactoryGirl.create(:image)
      Image.any_instance.should_receive(:save!)

      DownloadImage.perform(image.id, @url)
    end

    it "destroys the image when it has duplicate md5_checksum" do
      image1 = FactoryGirl.create(:image)
      image2 = FactoryGirl.create(:image)
      DownloadImage.perform(image1.id, @url)
      Image.should_receive(:destroy)
      DownloadImage.perform(image2.id, @url)
    end

    # rescueされたときはRails.loggerを呼ぶ
    it "writes a log when it crashes" do
      image = FactoryGirl.create(:image)
      Image.any_instance.stub(:image_from_url).and_raise
      expect(DownloadImage.logger).to receive(:error).exactly(1).times

      DownloadImage.perform(image.id, @url)
    end
  end
end