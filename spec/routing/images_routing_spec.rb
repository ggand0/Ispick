require "spec_helper"

describe ImagesController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/images")).to route_to("images#index")
    end

    it "routes to #show" do
      expect(get("/images/1")).to route_to("images#show", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/images/1")).to route_to("images#destroy", :id => "1")
    end

  end
end
