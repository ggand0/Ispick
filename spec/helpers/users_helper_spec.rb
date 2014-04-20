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
  describe "get_enabled_html" do
    it "returns valida html string" do
      target_word = FactoryGirl.create(:target_word)
      result = helper.get_enabled_html(target_word.enabled)
      expect(raw result).to eql('<strong>on</strong>')

      target_word.enabled = false
      result = helper.get_enabled_html(target_word.enabled)
      expect(raw result).to eql('<strong>off</strong>')
    end
  end
end
