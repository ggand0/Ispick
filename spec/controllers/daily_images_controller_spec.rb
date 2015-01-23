require 'spec_helper'

RSpec.describe DailyImagesController, :type => :controller do
  render_views
  let(:valid_session) { {} }
  #let(:default_params) { {format: :rss} }

  describe "GET rss" do
    it "renders DailyImage records in rss form" do
      FactoryGirl.create_list(:daily_image, 5)

      get :rss, format: 'rss'
      #puts response.body.inspect

      expect(response.body.match(/title1/)).not_to eq(nil)
      expect(response.body.match(/caption1/)).not_to eq(nil)
      #expect(response).to redirect_to('/signin_with_password')
    end
  end
end
