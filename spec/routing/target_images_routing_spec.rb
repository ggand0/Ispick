require "spec_helper"

describe TargetImagesController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/target_images")).to route_to("target_images#index")
    end

    it "routes to #new" do
      expect(get("/target_images/new")).to route_to("target_images#new")
    end

    it "routes to #show" do
      expect(get("/target_images/1")).to route_to("target_images#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/target_images/1/edit")).to route_to("target_images#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/target_images")).to route_to("target_images#create")
    end

    it "routes to #update" do
      expect(put("/target_images/1")).to route_to("target_images#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/target_images/1")).to route_to("target_images#destroy", :id => "1")
    end

  end
end
