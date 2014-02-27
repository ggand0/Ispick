require 'spec_helper'
require "#{Rails.root}/lib/utility_color"

describe Utility do
  describe "round_array" do
    it "returns an array" do
      data = [0, 0, 0]
      Utility::round_array(data).should be_a Array
    end

    it "returns a rounded array" do
      data = [0.11111, 0.22222, 0.33333]

      Utility::round_array(data, 1).should eq([0.1, 0.2, 0.3])
      Utility::round_array(data, 2).should eq([0.11, 0.22, 0.33])
      Utility::round_array(data, 3).should eq([0.111, 0.222, 0.333])
      Utility::round_array(data, 4).should eq([0.1111, 0.2222, 0.3333])
      Utility::round_array(data, 5).should eq([0.11111, 0.22222, 0.33333])
    end

    it "returns a valid rounded array with default argument" do
      data = [0.11111, 0.22222, 0.33333]
      Utility::round_array(data).should eq([0.11, 0.22, 0.33])
    end
  end

  describe "rgb_to_hsv" do
    it "returns an array" do
      rgb = [0, 0, 0]
      hsv = Utility::rgb_to_hsv(rgb[0], rgb[1], rgb[2], false)
      hsv.should be_a Array
    end

    it "returns valid values for basic colors" do
      # Red
      rgb = [255, 0, 0]
      hsv = Utility::rgb_to_hsv(rgb[0], rgb[1], rgb[2], false)
      hsv.should eq([0, 100, 100])

      # Green
      rgb = [0, 255, 0]
      hsv = Utility::rgb_to_hsv(rgb[0], rgb[1], rgb[2], false)
      hsv.should eq([120, 100, 100])

      # Blue
      rgb = [0, 0, 255]
      hsv = Utility::rgb_to_hsv(rgb[0], rgb[1], rgb[2], false)
      hsv.should eq([240, 100, 100])
    end

    it "returns valid values for other colors" do
      rgb = [10, 155, 200]
      hsv = Utility::rgb_to_hsv(rgb[0], rgb[1], rgb[2], false)
      # Check rounded value
      [hsv[0].round(1), hsv[1].round(1), hsv[2].round(1)].should eq([194, 95.0, 78.4])

      # Gray
      rgb = [128, 128, 128]
      hsv = Utility::rgb_to_hsv(rgb[0], rgb[1], rgb[2], false)
      [hsv[0].round(1), hsv[1].round(1), hsv[2].round(1)].should eq([0, 0.0, 50.2])

      # Purple
      rgb = [128, 0, 128]
      hsv = Utility::rgb_to_hsv(rgb[0], rgb[1], rgb[2], false)
      [hsv[0].round(1), hsv[1].round(1), hsv[2].round(1)].should eq([300, 100.0, 50.2])

      # Dark moderate red(#7f3f3f)
      rgb = [127, 63, 63]
      hsv = Utility::rgb_to_hsv(rgb[0], rgb[1], rgb[2], false)
      [hsv[0].round(1), hsv[1].round(1), hsv[2].round(1)].should eq([0.0, 50.4, 49.8])
    end

    it "returns valid value with cone model" do
      # Red
      rgb = [255, 0, 0]
      hsv = Utility::rgb_to_hsv(rgb[0], rgb[1], rgb[2], true)
      hsv.should eq([0, 100, 100])

      # Green
      rgb = [0, 255, 0]
      hsv = Utility::rgb_to_hsv(rgb[0], rgb[1], rgb[2], true)
      hsv.should eq([120, 100, 100])

      # Blue
      rgb = [0, 0, 255]
      hsv = Utility::rgb_to_hsv(rgb[0], rgb[1], rgb[2], true)
      hsv.should eq([240, 100, 100])
    end
  end

end