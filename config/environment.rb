# Load the Rails application.
require File.expand_path('../application', __FILE__)

# http://stackoverflow.com/questions/4911607/is-it-possible-to-set-env-variables-for-rails-development-environment-in-my-code
# Load the app's custom environment variables here, so that they are loaded before environments/*.rb
app_environment_variables = File.join(Rails.root, 'config', 'app_environment_variables.rb')
load(app_environment_variables) if File.exists?(app_environment_variables)

# http://stackoverflow.com/questions/4779773/how-do-i-change-the-load-order-of-initializers-in-rails-3
# Load global configurations
CONFIG = Hashie::Mash.new YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]

# Initialize the Rails application.
Ispick::Application.initialize!
