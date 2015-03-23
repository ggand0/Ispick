require 'spec_helper'

describe ImageBoard do
  describe "get_total_size method" do
    it "returns valid size of favored_images" do
      image_board = FactoryGirl.create(:image_boards)
      result = image_board.get_total_size
      expect(result).to eq(19381)
    end
  end
end
