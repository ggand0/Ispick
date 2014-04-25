require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the DeliveredImagesHelper. For example:
#
# describe DeliveredImagesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe DeliveredImagesHelper do
  describe "show_targetable function" do
    it "show target_image with image_tag" do
      delivered_image = FactoryGirl.create(:delivered_image_from_image)
      expect(helper.show_targetable(delivered_image)).to include('img')
    end
    it "returns valid string when target_word is not found" do
      delivered_image = FactoryGirl.create(:delivered_image_from_image)
      TargetImage.stub(:where).and_return([])
      # [TargetImage id=xx]
      expect(helper.show_targetable(delivered_image)).to include("[TargetImage id=#{delivered_image.targetable_id}]")
    end

    it "show target_word with text" do
      delivered_image = FactoryGirl.create(:delivered_image_from_word)
      expect(helper.show_targetable(delivered_image)).to include('まどか')
    end
    it "returns valid string when target_word is not found" do
      delivered_image = FactoryGirl.create(:delivered_image_from_word)
      TargetWord.stub(:where).and_return([])
      # [TargetWord id=xx]
      expect(helper.show_targetable(delivered_image)).to include("[TargetWord id=#{delivered_image.targetable_id}]")
    end

    it "returns empty string when no targetable objects are given" do
      delivered_image = FactoryGirl.create(:delivered_image_no_association)
      expect(helper.show_targetable(delivered_image)).to eq('')
    end
  end
end
