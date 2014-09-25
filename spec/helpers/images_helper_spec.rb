require 'spec_helper'

describe ImagesHelper do
  describe "get_sizeof_all method" do
    it "returns a valid size in megabytes" do
      image = FactoryGirl.create(:image_file)
      result = helper.get_sizeof_all

      # The size of spec/fixtures/files/madoka.png
      # image.data.size => 4.551[B]
      # bytes_to_megabytes(image.data.size) => 0.018[MB]
      expect(result).to eq(0.018)
    end
  end
end
