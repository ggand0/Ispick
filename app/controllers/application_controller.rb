class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # production環境のみ認証するように
  #http_basic_authenticate_with :name => ENV['BASIC_AUTH_NAME'], :password => ENV['BASIC_AUTH_PW'] if Rails.env.production?
  before_filter :authenticate

  protected

  def authenticate
    if CONFIG['perform_authentication']
      authenticate_or_request_with_http_basic do |username, password|
        username == CONFIG['username'] && password == CONFIG['password']
      end
    end
  end
end
