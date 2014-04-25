# http://stackoverflow.com/questions/3282655/ruby-on-rails-3-reload-lib-directory-for-each-request/4368838#4368838
if Rails.env == 'development'
  lib_reloader = ActiveSupport::FileUpdateChecker.new(Dir["#{Rails.root}/lib/"]) do
    Rails.application.reload_routes! # or do something better here
  end
  service_reloader = ActiveSupport::FileUpdateChecker.new(Dir["#{Rails.root}/app/services/"]) do
    Rails.application.reload_routes!
  end

  ActionDispatch::Callbacks.to_prepare do
    lib_reloader.execute_if_updated
    service_reloader.execute_if_updated
  end
end