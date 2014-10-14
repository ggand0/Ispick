Ispick::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Better errors gem
  BetterErrors::Middleware.allow_ip! ENV['TRUSTED_IP'] if ENV['TRUSTED_IP']

  # logger formatter config
  config.logger = Logger.new(config.paths["log"].first)
  config.logger.formatter = ActiveSupport::Logger::SimpleFormatter.new

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false


  # Don't care if the mailer can't send.
  # 開発時はfalseだと問題に気づくことができないためtrueにする
  config.action_mailer.raise_delivery_errors = true

  # Set the SMTP as delivery protocol
  # 送信プロトコルにSMTPを選択
  config.action_mailer.delivery_method = :smtp

  # Configure SMTP
  # SMTPの設定
  config.action_mailer.smtp_settings = {
    address: 'smtp.gmail.com',
    port: 587,
    authentication: :plain,
    domain: 'smtp.gmail.com',
    user_name: CONFIG['gmail_username'],
    password: CONFIG['gmail_password']
  }

  # Settings of exception_notification gem
  # Uncomment this if you need to debug
=begin
  config.middleware.use ExceptionNotification::Rack,
    :ignore_crawlers => %w{Googlebot bingbot},
    :ignore_exceptions => ['ActionView::TemplateError'] + ExceptionNotifier.ignored_exceptions,
    email: {
      sender_address: 'noreply@ispicks.com',
      exception_recipients: CONFIG['gmail_username'],
    }
=end
  config.action_mailer.delivery_method = :letter_opener


  config.action_mailer.default_url_options = {:host => "0.0.0.0:3000"}

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
end
