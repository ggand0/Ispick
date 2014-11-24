require 'spec_helper'

describe AuthorizationsController do

  let(:valid_session) { {} }

  before do
    login_user
  end

  describe "GET 'destroy'" do
    it "destroys the requested authorization" do
      authorization = FactoryGirl.create(:authorization)
      puts authorization.inspect
      puts controller.current_user.authorizations.inspect
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
