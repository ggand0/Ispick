require "spec_helper"

describe TargetWordsController do
  describe "routing" do

    it "routes to #index" do
      get("/target_words").should route_to("target_words#index")
    end

    it "routes to #new" do
      get("/target_words/new").should route_to("target_words#new")
    end

    it "routes to #show" do
      get("/target_words/1").should route_to("target_words#show", :id => "1")
    end

    it "routes to #edit" do
      get("/target_words/1/edit").should route_to("target_words#edit", :id => "1")
    end

    it "routes to #create" do
      post("/target_words").should route_to("target_words#create")
    end

    it "routes to #update" do
      put("/target_words/1").should route_to("target_words#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/target_words/1").should route_to("target_words#destroy", :id => "1")
    end

  end
end
