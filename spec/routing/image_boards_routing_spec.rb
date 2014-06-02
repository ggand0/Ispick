require "rails_helper"

RSpec.describe ImageBoardsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/image_boards").to route_to("image_boards#index")
    end

    it "routes to #new" do
      expect(:get => "/image_boards/new").to route_to("image_boards#new")
    end

    it "routes to #show" do
      expect(:get => "/image_boards/1").to route_to("image_boards#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/image_boards/1/edit").to route_to("image_boards#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/image_boards").to route_to("image_boards#create")
    end

    it "routes to #update" do
      expect(:put => "/image_boards/1").to route_to("image_boards#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/image_boards/1").to route_to("image_boards#destroy", :id => "1")
    end

  end
end
