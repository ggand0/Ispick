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
  describe "get_illust_html method" do
    it "returns a valid html" do
      delivered_image = FactoryGirl.create(:delivered_image)
      result = helper.get_illust_html(delivered_image.image)
      expect(result).to eql('Illust: <span><strong>true</strong></span>')
    end
  end

  describe "get_quality_html method" do
    it "returns a valid html" do
      delivered_image = FactoryGirl.create(:delivered_image)
      result = helper.get_quality_html(delivered_image.image)
      expect(result).to eql('Quality: <span><strong></strong></span>')
    end
  end

  describe "get_debug_html method" do
    it "returns a valid html" do
      user = FactoryGirl.create(:user_with_delivered_images)
      result = helper.get_debug_html(user.delivered_images)
      expect(result).to eql("<strong>Found 2 delivered_images.</strong>")
    end
  end


  # ===================
  #  Rendering helpers
  # ===================
  describe "render_delivered_image_button" do
    it "returns a valid html" do
      delivered_image = FactoryGirl.create(:delivered_image)
      image = delivered_image.image
      result = helper.render_delivered_image(delivered_image, image)
      expect(result.class).to eq(ActiveSupport::SafeBuffer)
    end
  end

  describe "render_clip_button" do
    it "returns a valid html" do
      delivered_image = FactoryGirl.create(:delivered_image)
      result = helper.render_clip_button(delivered_image)
      expect(result.class).to eq(ActiveSupport::SafeBuffer)

      id = delivered_image.id
      html = "<a class=\"popover-board btn-info btn-sm btn\" data-container=\"body\" data-placement=\"bottom\" data-remote=\"true\" data-toggle=\"popover\" href=\"/image_boards/boards?id=popover-board#{id}&amp;image=#{id}\" id=\"popover-board#{id}\">Clip</a>"
      expect(result.to_s).to eq(html)
    end
  end

  describe "render_hide_button" do
    it "returns a valid html" do
      delivered_image = FactoryGirl.create(:delivered_image)
      result = helper.render_hide_button(delivered_image)
      expect(result.class).to eq(ActiveSupport::SafeBuffer)
    end
  end

  describe "render_show_button" do
    it "returns a valid html" do
      delivered_image = FactoryGirl.create(:delivered_image)
      result = helper.render_show_button(delivered_image)
      expect(result.class).to eq(ActiveSupport::SafeBuffer)
    end
  end

end
