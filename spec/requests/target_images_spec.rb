require 'spec_helper'

describe "TargetImages" do
  describe "GET /target_images" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get target_images_path
      expect(response.status).to be(200)
    end
  end
end
