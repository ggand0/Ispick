require 'spec_helper'

describe ApplicationHelper do
  describe "bytes_to_megabytes" do
    it "returns valid value" do
      expect(helper.bytes_to_megabytes(100*1024*1024)).to eq(100)
    end
  end
  describe "get_total_size funciton" do
     it "returns valid value" do
      image1 = FactoryGirl.create(:image)
      image2 = FactoryGirl.create(:image)
      Image.any_instance.stub(:data).and_return(100)
      #puts image1.data.size # => 8(100が3bitだから？)
      expect(helper.get_total_size(Image.all)).to eq(image1.data.size+image2.data.size)
    end
  end
end
