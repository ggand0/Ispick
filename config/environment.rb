# Load the Rails application.
require File.expand_path('../application', __FILE__)

# http://stackoverflow.com/questions/4779773/how-do-i-change-the-load-order-of-initializers-in-rails-3
# Load global configurations
CONFIG = Hashie::Mash.new YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]

# Initialize the Rails application.
Ispick::Application.initialize!
