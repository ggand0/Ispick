require "spec_helper"

describe ImagesController do
  describe "routing" do

    it "routes to #index" do
      get("/images").should route_to("images#index")
    end

    it "routes to #show" do
      get("/images/1").should route_to("images#show", :id => "1")
    end

    it "routes to #destroy" do
      delete("/images/1").should route_to("images#destroy", :id => "1")
    end

  end
end
