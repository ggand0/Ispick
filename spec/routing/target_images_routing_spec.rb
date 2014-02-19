require "spec_helper"

describe TargetImagesController do
  describe "routing" do

    it "routes to #index" do
      get("/target_images").should route_to("target_images#index")
    end

    it "routes to #new" do
      get("/target_images/new").should route_to("target_images#new")
    end

    it "routes to #show" do
      get("/target_images/1").should route_to("target_images#show", :id => "1")
    end

    it "routes to #edit" do
      get("/target_images/1/edit").should route_to("target_images#edit", :id => "1")
    end

    it "routes to #create" do
      post("/target_images").should route_to("target_images#create")
    end

    it "routes to #update" do
      put("/target_images/1").should route_to("target_images#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/target_images/1").should route_to("target_images#destroy", :id => "1")
    end

  end
end
