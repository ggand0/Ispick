source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.2'#'3.2.16'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0', :git => 'https://github.com/rails/sass-rails.git'
#gem 'sass-rails', '~> 3.2.3', :git => 'https://github.com/rails/sass-rails.git'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0', :git => 'https://github.com/rails/coffee-rails.git'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
#gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

# added for image uploading by me
gem 'paperclip', '~> 3.0'

#gem 'linecache19', '>= 0.5.13', :git => 'https://github.com/robmathews/linecache19-0.5.13.git'
#gem 'ruby-debug-base19x', '>= 0.11.30.pre10'
#gem 'ruby-debug-ide', '>= 0.4.17.beta14'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

# rails consoleを起動するために必要
gem 'rb-readline', '~> 0.4.2'


group :development, :test do
	gem 'nokogiri'
	gem 'better_errors'								# Improve error page
  	gem 'binding_of_caller'
  	gem 'fuubar'									# テスト進行状況可視化
	gem 'guard'
	gem 'guard-coffeescript'
	gem 'guard-teaspoon'
	gem 'rb-fsevent'								# used by guard
	gem "phantomjs", ">= 1.8.1.1"
	gem 'mocha', '~> 0.14.0', :require => false
	gem 'teaspoon'
	gem 'jquery-fileupload-rails'					# Upload multiple files
	gem 'rspec-rails', '>= 2.6.0'					# Testing framework
  	gem "rails-erd"									# モデル関連図生成
  	gem 'simplecov'									# カバレッジ
	gem 'simplecov-rcov'
	gem 'pry-rails'									# Improve console
end
