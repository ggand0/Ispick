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

    it "show target_word with text" do
      delivered_image = FactoryGirl.create(:delivered_image_from_word)
      expect(helper.show_targetable(delivered_image)).to include('まどか')
    end

    it "show nothing when no targetable objects are given" do
      delivered_image = FactoryGirl.create(:delivered_image)
      expect(helper.show_targetable(delivered_image)).to eq(nil)
    end
  end
end
