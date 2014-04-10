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

  # 時間系
  describe "utc_to_jst method" do
    it "convert utc datetime properly" do
      image = FactoryGirl.create(:image)
      utc = DateTime.new(2014, 4, 1, 0, 0).utc
      jst = helper.utc_to_jst(ActiveSupport::TimeWithZone.new(utc, 'GMT'))

      expect(jst).to eq(DateTime.new(2014, 4, 1, 0, 0).in_time_zone('Asia/Tokyo'))
    end
  end
  describe "get_time_string method" do
    it "returns proper string from datetime value" do
      utc = DateTime.new(2014, 4, 1, 0, 0).utc
      created_at = ActiveSupport::TimeWithZone.new(utc, 'GMT')
      jst = helper.utc_to_jst(created_at)

      expect(helper.get_time_string(jst)).to eql('2014年04月01日09時00分')
    end
  end
  describe "get_jst_string method" do
    it "returns proper string from datetime value" do
      utc = DateTime.new(2014, 4, 1, 0, 0).utc
      created_at = ActiveSupport::TimeWithZone.new(utc, 'GMT')

      expect(helper.get_jst_string(created_at)).to eql('2014年04月01日09時00分')
    end
  end
end
