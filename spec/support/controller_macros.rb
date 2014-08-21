module ControllerMacros
  def login_user
    controller.stub(:authenticate_user!).and_return true
    @request.env["devise.mapping"] = Devise.mappings[:user]
    #user = FactoryGirl.create(:user)
    user = FactoryGirl.create(:user_with_target_word)
    sign_in user
  end

  def login_twitter_user
    controller.stub(:authenticate_user!).and_return true
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryGirl.create(:twitter_user)
    sign_in user
  end
end