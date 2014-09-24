require 'spec_helper'

describe AuthorizationsController do

  describe "GET 'destroy'" do
    it "destroys the requested authorization" do
      ization = FactoryGirl.create(:authorization)
      expect {
        delete :destroy, {:id => authorization.to_param}, valid_session
      }.to change(Authorization, :count).by(-1)
    end

    it "redirects to the authorizations list" do
      ization = FactoryGirl.create(:authorization)
      delete :destroy, {:id => authorization.to_param}, valid_session
      response.should redirect_to(settings_users_path)
    end
  end

end
