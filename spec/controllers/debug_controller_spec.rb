require 'spec_helper'

describe DebugController do

  describe "GET 'index'" do
    it "renders 'signin_with_password' template when the user is NOT logged in" do
      get :index
      expect(response).to redirect_to('/signin_with_password')
    end

    it "renders 'home' template when the user is logged in" do
      login_user
      get :index
      expect(response).to render_template('debug/index')
    end
  end


end
