source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.2'

# Use MySQL2 as the database for Active Record
gem 'mysql2'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0', :git => 'https://github.com/rails/sass-rails.git'

# View related gems
gem 'bootstrap-sass'
gem 'bootstrap-datepicker-rails'
gem 'rails-bootstrap-helpers'
gem 'bootstrap_form'
gem 'rails_bootstrap_navbar'

gem 'kaminari'                                    # Enable pagination
gem 'jquery-fileupload-rails'                     # Upload multiple files
gem 'remotipart', '~> 1.2'                        # Enable ajax request with form_tag
gem 'high_voltage', '~> 2.1.0'                    # Handles static pages

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0', :git => 'https://github.com/rails/coffee-rails.git'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
#gem 'therubyracer', platforms: :ruby
gem 'libv8', '~> 3.11.8.13'
gem 'therubyracer'#, '0.11.0beta8'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

# added for image uploading by me
gem 'paperclip', '~> 3.0'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use puma as the app server
gem 'puma'

# Console
gem 'rb-readline', '0.5.0', require: false       # rails consoleを起動するために必要
gem 'pry-rails'                                  # Improve the console

# OAuth
gem 'devise'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-pinterest'

# System
gem 'nokogiri'                                   # For scraping
gem 'mechanize'
gem 'rmagick', require: false                    # Image processing lib. Used by AnimeFace
gem 'resque'                                     # For background jobs
gem 'resque-web', require: 'resque_web'          # Web interface for resque
gem 'daemon-spawn', require: 'daemon_spawn'
gem 'pidfile'
gem 'whenever', require: false                   # Support crontab
gem 'rubyzip'
gem 'ransack'

# API clients
gem 'natto'
gem 'x2ch'
gem 'futaba', git: 'git@github.com:pentiumx/futaba.git'
gem 'twitter', '>= 5.8.0', git: 'git@github.com:pentiumx/twitter.git'
gem 'tumblr_client', git: 'https://github.com/tumblr/tumblr_client.git'
gem 'giphy'

group :test do
  gem 'webmock'                                     # developmentからは外す必要有り
end

group :development, :test do
  gem 'better_errors'                               # Improve error page
  gem 'binding_of_caller'
  gem 'fakeweb', '~> 1.3'                           # Mock urls
  gem 'rails-erd'                                   # モデル関連図生成

  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'guard'
  gem 'guard-rspec', '4.2.0', require: false
  #gem 'guard-coffeescript'
  gem 'guard-teaspoon'
  #gem 'rb-fsevent', require: false                 # Used by guard and spring


  # Rails testing
  gem 'rspec-rails', '~> 2.99.0'                     # Testing framework
  gem 'factory_girl_rails'                          # A fixtures replacement
  gem 'simplecov'                                   # カバレッジ測定
  gem 'simplecov-rcov'
  gem 'fuubar'                                      # テスト進行状況可視化
  gem 'rake_shared_context'                         # Enable rake task testing
  gem 'capybara'
  gem 'launchy'                                     # save_and_open_page

  # JS testing
  gem 'teaspoon'                                    # JS test runner
  gem 'phantomjs', '>= 1.8.1.1'
  #gem 'mocha', '~> 0.14.0', :require => false      # rspecと競合するので凍結中

  # Deploy
  gem 'capistrano', '~> 3.1.0'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv', '~> 2.0'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'capistrano-ext'                              # 環境毎に設定を変更するためのgem
  gem 'capistrano3-puma'
  gem 'capistrano-puma', require: false
end
