require "spec_helper"

describe DeliveredImagesController do
  describe "routing" do

    it "routes to #index" do
      get("/delivered_images").should route_to("delivered_images#index")
    end

    it "routes to #new" do
      get("/delivered_images/new").should route_to("delivered_images#new")
    end

    it "routes to #show" do
      get("/delivered_images/1").should route_to("delivered_images#show", :id => "1")
    end

    it "routes to #edit" do
      get("/delivered_images/1/edit").should route_to("delivered_images#edit", :id => "1")
    end

    it "routes to #create" do
      post("/delivered_images").should route_to("delivered_images#create")
    end

    it "routes to #update" do
      put("/delivered_images/1").should route_to("delivered_images#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/delivered_images/1").should route_to("delivered_images#destroy", :id => "1")
    end

  end
end
