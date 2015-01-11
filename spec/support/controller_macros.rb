# Provides login methods that create and sign in oauth users
module ControllerMacros

  # Creates a user who signed in via Twitter who already followed some tags,
  # and make it log in.
  def login_user
    #controller.stub(:authenticate_user!).and_return true
    allow(controller).to receive(:authenticate_user!).and_return true
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryGirl.create(:user_with_tag)
    sign_in user
  end

  # Creates a user who signed in via Twitter, and make it log in.
  def login_twitter_user
    controller.stub(:authenticate_user!).and_return true
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryGirl.create(:twitter_user)
    sign_in user
  end
end