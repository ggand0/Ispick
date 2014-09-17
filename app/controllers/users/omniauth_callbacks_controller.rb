class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def twitter
    # Error handling
    if request.env["omniauth.auth"].nil? or
      request.env["omniauth.auth"]['provider'].nil?
      redirect_to new_user_registration_url
      return
    end

    # You need to implement the method below in your model
    @user = User.find_for_twitter_oauth(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      set_flash_message(:notice, :success, :kind => "Twitter") if is_navigational_format?
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.twitter_data"] = request.env["omniauth.auth"].except("extra")
      redirect_to new_user_registration_url
    end
  end

  def tumblr
    @user = User.find_for_tumblr_oauth(request.env["omniauth.auth"], current_user)

    # Save oauth tokens to the session
    session[:oauth_token] = request.env["omniauth.auth"]["extra"]["access_token"].params[:oauth_token]
    session[:oauth_token_secret] = request.env["omniauth.auth"]["extra"]["access_token"].params[:oauth_token_secret]

    if @user.persisted?
      set_flash_message(:notice, :success, :kind => "Tumblr") if is_navigational_format?
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.tumblr_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end



end
