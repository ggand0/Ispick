require 'spec_helper'

# Will add more examples
# 参考：https://gist.github.com/jittuu/792715
describe Users::OmniauthCallbacksController do
  let(:home_path) { 'http://test.host/users/home' }


  before :each do
    # This a Devise specific thing for functional tests.
    # See https://github.com/plataformatec/devise/issues/closed#issue/608
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "twitter method" do
    it "should redirect back to sign_up page with an error when omniauth.auth is missing" do
      @controller.stub(:env).and_return({"some_other_key" => "some_other_value"})
      get :twitter
      response.should redirect_to new_user_registration_url
    end

    it "should redirect back to sign_up page with an error when provider is missing" do
      stub_env_for_omniauth(nil)
      get :twitter
      response.should redirect_to new_user_registration_url
    end

    it "should redirect to sign_up page when it can NOT find the user" do
      stub_env_for_omniauth
      User.any_instance.stub(:persisted?).and_return(false)
      get :twitter
      response.should redirect_to new_user_registration_url
    end

    it "should redirect to user home page when it can find the user" do
      stub_env_for_omniauth
      get :twitter
      response.should redirect_to home_path
    end
  end
end


# helper method
def stub_env_for_omniauth(provider = "twitter", uid = "1234567", name = "John Doe")
  OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
    provider: provider,
    uid: uid,
    info: { nickname: name},
    credentials: OmniAuth::AuthHash.new({})
  })
  request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
end