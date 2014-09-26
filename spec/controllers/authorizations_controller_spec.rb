require 'spec_helper'

describe AuthorizationsController do

  let(:valid_session) { {} }

  describe "GET 'destroy'" do
    it "destroys the requested authorization" do
      authorization = FactoryGirl.create(:authorization)
      expect {
        delete :destroy, {:id => authorization.to_param}, valid_session
      }.to change(Authorization, :count).by(-1)
    end

    it "redirects to the authorizations list" do
      authorization = FactoryGirl.create(:authorization)
      delete :destroy, {:id => authorization.to_param}, valid_session
      response.should redirect_to(settings_users_path)
    end
  end

end
