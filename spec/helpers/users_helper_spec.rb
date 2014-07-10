require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the UsersHelper. For example:
#
# describe UsersHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe UsersHelper do
  describe "get_clip_string method" do
    it "returns valid string" do
      image = FactoryGirl.create(:delivered_image)
      expect(helper.get_clip_string(image)).to eq('Clip')

      image = FactoryGirl.create(:favored_image_with_delivered)
      expect(helper.get_clip_string(image.delivered_image)).to eq('Clipped')
    end
  end

  describe "get_clip_string_styled" do
    it "returns valid string" do
      image = FactoryGirl.create(:delivered_image)
      expect(raw helper.get_clip_string_styled(image)).to eq('<span style="color: #000;">Clip</span>')

      image = FactoryGirl.create(:favored_image_with_delivered)
      expect(raw helper.get_clip_string_styled(image.delivered_image)).to eq(
        '<span style="color: #02C293;">Clipped</span>')
    end
  end

  describe "get_illust_html method" do
    it "returns valid html" do
      delivered_image = FactoryGirl.create(:delivered_image)
      result = helper.get_illust_html(delivered_image.image)
      expect(result).to eql('Illust: <span><strong>true</strong></span>')
    end
  end

end
