class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #before_filter :authenticate
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :miniprofiler
  before_filter :your_function
  after_filter  :expire_for_development

  def authenticate_admin_user!
    redirect_to new_user_session_path  unless current_admin
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
        home_users_path
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

  def your_function
    @controller = controller_name
    @action = action_name
  end

  def set_cache_headers
    response.headers["Cache-Control"] = "private, no-cache, no-store, max-age=0, must-revalidate, post-check=0, pre-check=0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def expire_for_development
    expires_now if Rails.env.development?
  end
end
