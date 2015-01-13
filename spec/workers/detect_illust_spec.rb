require 'spec_helper'
require "#{Rails.root}/app/workers/detect_illust"

describe DetectIllust do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image) }

  before do
    allow_any_instance_of(IO).to receive(:puts)             # Suppress console outputs
  end

  describe "get_result method" do
    it "execute the tool and returns value" do
      tool_path = CONFIG['illust_detection_path']
      image = Image.create! valid_attributes

      expect(DetectIllust).to receive(:`).once.with("#{tool_path} #{image.data.path} #{DetectIllust::QUALITY_SIZE}")
      DetectIllust.get_result(tool_path, image)
    end

    # IF this example failed, prolly your tool_path is wrong.
    it "correctly executed result should not to be NIL" do
      tool_path = CONFIG['illust_detection_path']
      image = FactoryGirl.create(:image_file)

      result = DetectIllust.get_result(tool_path, image)
      expect(result).not_to eq(nil)
    end
  end

  describe "perform method" do
    it "updates 'is_illust' column with true when result is '1'" do
      image = Image.create! valid_attributes
      allow(DetectIllust).to receive(:get_result).and_return('1')

      detect = DetectIllust.new
      DetectIllust::perform(image.id)

      expect(Image.find(image.id).is_illust).to eq(true)
    end

    it "updates 'is_illust' column with false when result is '0'" do
      image = Image.create! valid_attributes
      allow(DetectIllust).to receive(:get_result).and_return('0')

      detect = DetectIllust.new
      DetectIllust::perform( image.id)

      expect(Image.find(image.id).is_illust).to eq(false)
    end

    it "updates 'is_illust' column with false when fails to get valid result" do
      image = Image.create! valid_attributes
      allow(DetectIllust).to receive(:get_result).and_return('invalid return value')

      detect = DetectIllust.new
      DetectIllust::perform(image.id)

      expect(Image.find(image.id).is_illust).to eq(false)
    end

    it "writes a log when it crashes" do
      image = FactoryGirl.create(:image)
      allow(DetectIllust).to receive(:get_result).and_raise
      expect(DetectIllust.logger).to receive(:error).exactly(1).times

      DetectIllust.perform(image.id)
    end
  end
end