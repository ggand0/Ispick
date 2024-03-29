require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the TargetImagesHelper. For example:
#
# describe TargetImagesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end

describe TargetImagesHelper do
  let(:valid_attributes) { FactoryGirl.attributes_for(:target_image) }

  describe "paginate_zero method" do
    it "should return notice string if array size is zero" do
      expect(helper.paginate_zero([])).to eq('No matches.')
    end

    # ref: https://github.com/amatsuda/kaminari/blob/master/spec/helpers/action_view_extension_spec.rb
    it "should return pagination otherwise" do
      TargetImage.create! valid_attributes
      TargetImage.create! valid_attributes
      TargetImage.create! valid_attributes
      target_image = TargetImage.all.page(1)

      expect(helper.paginate_zero(target_image)).to be_a(String)
    end
  end

  describe "paginate_target_images method" do
    it "should return message argument if it is not empty" do
      expect(helper.paginate_target_images('Not extracted yet.', [])).to eq('Not extracted yet.')
    end

    it "should return notice string if array size is zero" do
      expect(helper.paginate_target_images('', [])).to eq('No matches.')
    end

    # ref: https://github.com/amatsuda/kaminari/blob/master/spec/helpers/action_view_extension_spec.rb
    it "should return pagination otherwise" do
      TargetImage.create! valid_attributes
      TargetImage.create! valid_attributes
      TargetImage.create! valid_attributes
      target_image = TargetImage.all.page(1)

      expect(helper.paginate_target_images('', target_image)).to be_a(String)
    end
  end

end
