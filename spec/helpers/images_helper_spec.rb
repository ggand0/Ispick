require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the ImagesHelper. For example:
#
# describe ImagesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe ImagesHelper do
  describe "get_sizeof_all method" do
    it "returns a valid size in megabytes" do
      FactoryGirl.create(:image_file)
      result = helper.get_sizeof_all

      # The size of spec/fixtures/files/madoka.png
      # Note that this value appears in windows systems.
      expect(result).to eq(4.551)
    end
  end
end
