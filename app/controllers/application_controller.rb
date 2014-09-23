class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :miniprofiler

  def authenticate_admin_user!
    #redirect_to new_user_session_path unless current_admin
    redirect_to '/' unless current_admin
  end

  protected

  # production環境のみBASIC認証する
  def authenticate
    if CONFIG['perform_authentication']
      authenticate_or_request_with_http_basic do |username, password|
        username == CONFIG['username'] && password == CONFIG['password']
      end
    end
  end

  # ログアウト後のリダイレクト先を指定する
  def after_sign_out_path_for(resource)
    root_path
  end

  # ログイン後のリダイレクト先を指定する
  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if resource.is_a?(Admin)
        admin_dashboard_path
      else
        user_path(resource)
      end
  end

  # Sign up時にname attributeを関連づける
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
  end

  # Run miniprofiler also in production environment
  def miniprofiler
    Rack::MiniProfiler.authorize_request
    Rack::MiniProfiler.config.position = 'left'
  end
end
