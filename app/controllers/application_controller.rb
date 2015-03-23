class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #before_filter :authenticate
  before_filter :set_cache_headers
  before_filter :set_search
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :miniprofiler
  before_filter :your_function
  after_filter  :expire_for_development

  def authenticate_admin_user!
    redirect_to new_user_session_path  unless current_admin
  end

  def check_for_mobile
    session[:mobile_override] = params[:mobile] if params[:mobile]
  end

  def mobile_device?
    if session[:mobile_override]
      session[:mobile_override] == "1"
    else
      # Season this regexp to taste. I prefer to treat iPad as non-mobile.
      (request.user_agent =~ /Mobile|webOS/) && (request.user_agent !~ /iPad/)
    end
  end

  helper_method :mobile_device?

  protected

  # Set @search variable to make ransack's search form work
  def set_search
    @search = Image.search(params[:q])
  end

  # Set BASIC auth only in production env
  def authenticate
    if CONFIG['perform_authentication']
      authenticate_or_request_with_http_basic do |username, password|
        username == CONFIG['username'] && password == CONFIG['password']
      end
    end
  end

  # Specify the redirect location after logout
  def after_sign_out_path_for(resource)
    root_path
  end

  # Specify the redirect location after login
  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if resource.is_a?(Admin)
        admin_dashboard_path
      else
        home_users_path
      end
  end

  # Associate name attribute when signup
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
  end

  # Run miniprofiler also in production environment
  def miniprofiler
    Rack::MiniProfiler.authorize_request
    Rack::MiniProfiler.config.position = 'left'
  end

  def your_function
    @controller_name = controller_name
    @action_name = action_name
  end

  def set_cache_headers
    response.headers["Cache-Control"] = "private, no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def expire_for_development
    expires_now if Rails.env.development?
  end
end
