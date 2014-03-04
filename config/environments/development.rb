Ispic::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # 外部からサーバーにアクセスして開発する時(実行環境がcentosで開発環境がwindowsに有る時など)に設定する：
  # lib/development.local.sample.rbをリネームし、Local::IPの値を開発マシンIPに書き換える
  require "#{Rails.root}/lib/development.local.rb"
  Local::IP.each do |ip|
    BetterErrors::Middleware.allow_ip! ip if ip
  end

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
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
end
