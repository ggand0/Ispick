source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.2'

# Use MySQL2 as the database for Active Record
gem 'mysql2'

# Use SCSS for stylesheets
gem 'sass-rails', :git => 'https://github.com/rails/sass-rails.git'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', :git => 'https://github.com/rails/coffee-rails.git'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
#gem 'therubyracer', platforms: :ruby
gem 'libv8', '~> 3.11.8.13'
gem 'therubyracer'#, '0.11.0beta8'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

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
gem 'rb-readline', require: false                   # Necessary to launch rails console


# API clients
gem 'natto'
gem 'x2ch'
gem 'futaba', git: 'git@github.com:pentiumx/futaba.git'
gem 'twitter', '>= 5.8.0', git: 'git@github.com:pentiumx/twitter.git'
gem 'tumblr_client', git: 'https://github.com/tumblr/tumblr_client.git'
gem 'giphy'
gem 'tinami'


# OAuth gems
gem 'devise'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-pinterest'
gem 'omniauth-tumblr'

# Manages sharing on social networks
gem 'shareable'
#gem "social-buttons", '~> 0.3', git: 'git@github.com:pentiumx/social-buttons.git'
gem "social-buttons", git: 'git@github.com:pentiumx/social-buttons.git'

# System related gems
gem 'nokogiri'                                        # For scraping
gem 'mechanize'
gem 'rmagick', require: false                         # For image processing
gem 'resque'                                          # For background jobs
gem 'resque-web', require: 'resque_web'               # Web interface for resque
gem 'resque-logger'
gem 'daemon-spawn', require: 'daemon_spawn', git: 'git@github.com:pentiumx/daemon-spawn.git'
gem 'pidfile'
gem 'whenever', require: false                        # Support crontab
gem 'rubyzip'
gem 'ransack', github: 'activerecord-hackery/ransack'
gem 'factory_girl_rails'                              # A fixtures replacement
gem 'engtagger'
gem 'letter_opener', group: :development              # Open emails on browser
gem 'activeadmin', github: 'activeadmin'
gem 'obscenity', git: 'git@github.com:pentiumx/obscenity.git'
gem 'fastimage'
gem 'google-analytics-rails'
gem 'turnout'
gem 'impressionist'                                   # For the rakning page


# Twitter Bootstrap gems
gem 'bootstrap-sass', '~> 3.2.0'
gem 'autoprefixer-rails'
gem 'bootstrap-datepicker-rails'
gem 'rails-bootstrap-helpers'
gem 'bootstrap_form'
gem 'rails_bootstrap_navbar'

# Other view related gems
gem 'kaminari'                                    # Enable pagination
gem 'jquery-fileupload-rails'                     # Upload multiple files
gem 'remotipart', '~> 1.2'                        # Enable ajax request with form_tag
gem 'high_voltage', '~> 2.1.0'                    # Handles static pages
gem 'rack-mini-profiler'                          # For debugging loading times
gem 'font-awesome-rails'


# Logging and notification
group :production do
  gem 'exception_notification'                    # Notify errors with emails

  # Gems for centralized logging
  gem 'act-fluent-logger-rails'
  gem 'lograge'
  gem 'fluent-plugin-parser'
  #gem 'ltsv-logger'
end

# Mock urls during testing
group :test do
  gem 'webmock'
  gem 'fakeweb', '~> 1.3'
end

group :development, :test do

  # Utilities
  gem 'better_errors'                               # Improve error page
  gem 'binding_of_caller'
  gem 'rails-erd'                                   # Generates domain model diagram
  gem 'quiet_assets'                                # Turns off the Rails asset pipeline log
  gem 'diffy'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'guard'
  gem 'guard-rspec', '4.2.0', require: false
  gem 'guard-teaspoon'
  #gem 'guard-coffeescript'
  #gem 'rb-fsevent', require: false                 # Used by guard and spring
  #gem 'pry-rails'                                  # Improve the console
  #gem 'pry-nav'


  # RSpec
  gem 'rspec-rails', '~> 3.0.0.beta1'               # Testing framework
  #gem 'rspec-its'                                   # Provides the 'its' method
  gem 'rspec-activemodel-mocks'                     # Provides tools for testing ActiveModel classes
  gem 'simplecov', :require => false                # Measure coverage
  gem 'simplecov-rcov', :require => false
  gem 'fuubar'                                      # Visualise the process during running specs
  gem 'rake_shared_context'                         # Enable rake task testing
  gem 'transpec'

  # Integration testing
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'selenium-webdriver'
  gem 'database_cleaner'
  gem 'launchy'                                     # Enable save_and_open_page method

  # JS testing
  gem 'teaspoon'                                    # JS test runner
  gem 'phantomjs', '>= 1.8.1.1'                     # A headless WebKit
  gem 'jasmine'                                     # JS testing framework
  gem 'jasmine-jquery-rails'

  # Deploying
  gem 'capistrano', '~> 3.1.0'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv', '~> 2.0'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'capistrano-ext'                              # A gem to change settings according to environments
  gem 'capistrano3-puma'
  gem 'capistrano-puma', require: false
end
