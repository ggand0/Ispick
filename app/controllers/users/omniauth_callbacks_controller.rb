class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :authenticate_user!

  def all
    # Error handling
    if request.env["omniauth.auth"].nil? or
      request.env["omniauth.auth"]['provider'].nil?
      redirect_to new_user_registration_url
      return
    end

    user = User.from_omniauth(request.env["omniauth.auth"], current_user)
    if user.persisted?
      sign_in_and_redirect(user)
    else
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_url
    end
  end

  def failure
    # handle you logic here..
    # and delegate to super.
    super
  end


  alias_method :facebook, :all
  alias_method :twitter, :all
  alias_method :tumblr, :all
end
