class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # production環境のみBASIC認証する
  before_filter :authenticate
  # Sign up時にname attributeを関連づける
  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  def authenticate
    if CONFIG['perform_authentication']
      authenticate_or_request_with_http_basic do |username, password|
        username == CONFIG['username'] && password == CONFIG['password']
      end
    end
  end

  def after_sign_out_path_for(resource)
    root_path
  end
  def after_sign_in_path_for(resource)
    '/users/home'
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
  end
end
