require 'spec_helper'
require "#{Rails.root}/lib/utility_color"

describe Utility do
  let(:valid_hash) { [{"likelihood"=>1.0, "skin_color"=>{"blue"=>252, "green"=>253, "red"=>251},
    "hair_color"=>{"blue"=>156, "green"=>182, "red"=>98},
    "eyes"=>{"left"=>{"colors"=>{"blue"=>79, "green"=>87, "red"=>67}}, "right"=>{"colors"=>{"blue"=>61, "green"=>70, "red"=>44}}}}]
  }

  describe "evaluate_face_colors function" do
    it "should return valid evaluation value" do
      distance = { hair: 30, skin: 100, left_eye: 100, right_eye: 100 }
      Utility.evaluate_face_colors(distance, [3, 1, 1, 1]).should eq(390)
    end
  end

  describe "is_preferred function" do
    it "should return true with preferred image" do
      distance = { hair: 30, skin: 100, left_eye: 100, right_eye: 100 }
      Utility.is_preferred(distance, [30, 100, 100, 100]).should eq(true)
    end

    it "should return false with NOT preferred image" do
      distance = { hair: 31, skin: 100, left_eye: 100, right_eye: 100 }
      Utility.is_preferred(distance, [30, 100, 100, 100]).should eq(false)

      distance = { hair: 30, skin: 101, left_eye: 100, right_eye: 100 }
      Utility.is_preferred(distance, [30, 100, 100, 100]).should eq(false)

      distance = { hair: 30, skin: 100, left_eye: 101, right_eye: 100 }
      Utility.is_preferred(distance, [30, 100, 100, 100]).should eq(false)

      distance = { hair: 30, skin: 100, left_eye: 100, right_eye: 101 }
      Utility.is_preferred(distance, [30, 100, 100, 100]).should eq(false)
    end
  end


  describe "get_hsv_distance" do
    it "should return a distance hash" do
      color_hash0 = { hair: [0, 0, 0], skin: [0, 0, 0], left_eye:[0, 0, 0], right_eye:[0, 0, 0] }
      color_hash1 = { hair: [10, 0, 0], skin: [10, 0, 0], left_eye:[10, 0, 0], right_eye:[10, 0, 0] }

      dist_hash = Utility.get_hsv_distance(color_hash0, color_hash1)
      dist_hash.should be_a(Hash)
      dist_hash[:hair].should eq(10)
      dist_hash[:skin].should eq(10)
      dist_hash[:left_eye].should eq(10)
      dist_hash[:right_eye].should eq(10)
    end
  end

  describe "hsv_distance" do
    it "should return a distance" do
      dist = Utility.hsv_distance([0, 0, 0], [10, 0, 0])
      dist.should eq(10)
    end
  end

  describe "get_colors" do
    it "should return a hash" do
      hash = Utility::get_colors(valid_hash[0], false)
      hash.should be_a(Hash)

      hash = Utility::get_colors(valid_hash[0], true)
      hash.should be_a(Hash)
    end
  end

  describe "get_eye_color" do
    it "should return rgb array with valid hash" do
      rgb = Utility::get_eye_color(valid_hash[0], 'left')
      rgb.should be_an(Array)

      rgb = Utility::get_eye_color(valid_hash[0], 'right')
      rgb.should be_an(Array)
    end
  end

  describe "get_face_color" do
    it "should return rgb array with valid hash" do
      rgb = Utility::get_face_color(valid_hash[0], 'hair_color')
      rgb.should be_an(Array)

      rgb = Utility::get_face_color(valid_hash[0], 'skin_color')
      rgb.should be_an(Array)
    end
  end

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
      hsv = Utility::rgb_to_hsv(rgb, false)
      hsv.should be_a Array
    end

    it "returns valid values for basic colors" do
      # Red
      rgb = [255, 0, 0]
      hsv = Utility::rgb_to_hsv(rgb, false)
      hsv.should eq([0, 100, 100])

      # Green
      rgb = [0, 255, 0]
      hsv = Utility::rgb_to_hsv(rgb, false)
      hsv.should eq([120, 100, 100])

      # Blue
      rgb = [0, 0, 255]
      hsv = Utility::rgb_to_hsv(rgb, false)
      hsv.should eq([240, 100, 100])
    end

    it "returns valid values for other colors" do
      rgb = [10, 155, 200]
      hsv = Utility::rgb_to_hsv(rgb, false)
      # Check rounded value
      [hsv[0].round(1), hsv[1].round(1), hsv[2].round(1)].should eq([194, 95.0, 78.4])

      # Gray
      rgb = [128, 128, 128]
      hsv = Utility::rgb_to_hsv(rgb, false)
      [hsv[0].round(1), hsv[1].round(1), hsv[2].round(1)].should eq([0, 0.0, 50.2])

      # Purple
      rgb = [128, 0, 128]
      hsv = Utility::rgb_to_hsv(rgb, false)
      [hsv[0].round(1), hsv[1].round(1), hsv[2].round(1)].should eq([300, 100.0, 50.2])

      # Dark moderate red(#7f3f3f)
      rgb = [127, 63, 63]
      hsv = Utility::rgb_to_hsv(rgb, false)
      [hsv[0].round(1), hsv[1].round(1), hsv[2].round(1)].should eq([0.0, 50.4, 49.8])
    end

    it "returns valid value with cone model" do
      # Red
      rgb = [255, 0, 0]
      hsv = Utility::rgb_to_hsv(rgb, true)
      hsv.should eq([0, 100, 100])

      # Green
      rgb = [0, 255, 0]
      hsv = Utility::rgb_to_hsv(rgb, true)
      hsv.should eq([120, 100, 100])

      # Blue
      rgb = [0, 0, 255]
      hsv = Utility::rgb_to_hsv(rgb, true)
      hsv.should eq([240, 100, 100])
    end
  end

end