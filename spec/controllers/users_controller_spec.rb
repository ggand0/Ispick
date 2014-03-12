require 'spec_helper'

describe UsersController do
  let(:valid_session) { {} }

  describe "GET home" do
    it "should render signed_in template when logged in" do
      login_user
      get :home, {}, valid_session
      response.should render_template('signed_in')
      sign_out :user
    end

    it "should render not_signed_in template when not logged in" do
      get :home, {}, valid_session
      response.should render_template('not_signed_in')
    end
  end
end
