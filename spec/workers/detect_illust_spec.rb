require 'spec_helper'
require "#{Rails.root}/app/workers/detect_illust"

describe DetectIllust do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image) }

  before do
    IO.any_instance.stub(:puts)
  end

  describe "get_result method" do
    it "execute the tool and returns value" do
      tool_path = CONFIG['illust_detection_path']
      image = Image.create! valid_attributes

      DetectIllust.should_receive(:`).once.with("#{tool_path} #{image.data.path}")

      DetectIllust.get_result(tool_path, image)
    end
  end

  describe "perform method" do
    it "updates 'is_illust' column with true when result is '1'" do
      image = Image.create! valid_attributes
      DetectIllust.stub(:get_result).and_return('1')

      detect = DetectIllust.new
      DetectIllust::perform(image.class.name, image.id)

      expect(Image.find(image.id).is_illust).to eq(true)
    end

    it "updates 'is_illust' column with false when result is '0'" do
      image = Image.create! valid_attributes
      DetectIllust.stub(:get_result).and_return('0')

      detect = DetectIllust.new
      DetectIllust::perform(image.class.name, image.id)

      expect(Image.find(image.id).is_illust).to eq(false)
    end

    it "updates 'is_illust' column with false when fails to get valid result" do
      image = Image.create! valid_attributes
      DetectIllust.stub(:get_result).and_return('invalid return value')

      detect = DetectIllust.new
      DetectIllust::perform(image.class.name, image.id)

      expect(Image.find(image.id).is_illust).to eq(false)
    end

    it "writes a log when it crashes" do
      image = FactoryGirl.create(:image)
      DetectIllust.stub(:get_result).and_raise
      Rails.logger.should_receive(:error).exactly(1).times

      DetectIllust.perform(image.class.name, image.id)
    end
  end
end