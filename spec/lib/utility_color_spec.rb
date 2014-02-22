require 'spec_helper'
require "#{Rails.root}/lib/utility_color"

describe Utility do
  describe "rgb_to_hsv" do
    it "returns hsv array" do
      r = 0
      g = 0
      b = 0
      hsv = Utility::rgb_to_hsv(r, g, b, false)
      hsv.should be_a Array
    end
  end

  describe "round_array" do
    it "returns rounded array" do
      data = [0.1111, 0.1111, 0.2222]
      data = Utility::round_array(data)
      data.should be_a Array
    end
  end
end