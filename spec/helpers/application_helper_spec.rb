require 'spec_helper'

describe ApplicationHelper do

  # ===========================
  #  File size related methods
  # ===========================
  describe "bytes_to_megabytes" do
    it "returns valid value" do
      expect(helper.bytes_to_megabytes(100*1024*1024)).to eq(100)
    end
  end

  describe "get_total_size funciton" do
    it "returns valid value" do
      image1 = FactoryGirl.create(:image)
      image2 = FactoryGirl.create(:image)
      allow_any_instance_of(Image).to receive(:data).and_return(100)
      #puts image1.data.size # => 8(100が3bitだから？)

      expect(helper.get_total_size(Image.all)).to eq(image1.data.size+image2.data.size)
    end

    it "returns 0 if the array is nil" do
      expect(helper.get_total_size([])).to eq(0)
    end

    # Image.dataがnilもしくはrelationの中にnilの要素が含まれていた場合、
    # それらはカウントの対象としない事
    it "ignores nil items" do
      image1 = FactoryGirl.create(:image_file)  # data有り: size>0
      image2 = FactoryGirl.create(:image)       # data無し: size=0

      expect(helper.get_total_size([image1, image2, nil])).to eq(image1.data.size)
    end
  end



  # =============================
  #  Time related helper methods
  # =============================
  describe "utc_to_jst method" do
    it "convert utc datetime properly" do
      image = FactoryGirl.create(:image)
      utc = DateTime.new(2014, 4, 1, 0, 0).utc
      jst = helper.utc_to_jst(ActiveSupport::TimeWithZone.new(utc, 'GMT'))

      expect(jst).to eq(DateTime.new(2014, 4, 1, 0, 0).in_time_zone('Asia/Tokyo'))
    end
  end

  describe "get_time_string_ja method" do
    it "returns proper string from datetime value" do
      utc = DateTime.new(2014, 4, 1, 0, 0).utc
      created_at = ActiveSupport::TimeWithZone.new(utc, 'GMT')
      jst = helper.utc_to_jst(created_at)

      expect(helper.get_time_string_ja(jst)).to eql('2014年04月01日09時00分')
    end
  end

  describe "get_jst_string_ja method" do
    it "returns proper string from datetime value" do
      utc = DateTime.new(2014, 4, 1, 0, 0).utc
      created_at = ActiveSupport::TimeWithZone.new(utc, 'GMT')

      expect(helper.get_jst_string_ja(created_at)).to eql('2014年04月01日09時00分')
    end
  end
end
