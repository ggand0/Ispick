require "spec_helper"

describe TargetWordsController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/target_words")).to route_to("target_words#index")
    end

    it "routes to #new" do
      expect(get("/target_words/new")).to route_to("target_words#new")
    end

    it "routes to #show" do
      expect(get("/target_words/1")).to route_to("target_words#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/target_words/1/edit")).to route_to("target_words#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/target_words")).to route_to("target_words#create")
    end

    it "routes to #update" do
      expect(put("/target_words/1")).to route_to("target_words#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/target_words/1")).to route_to("target_words#destroy", :id => "1")
    end

  end
end
