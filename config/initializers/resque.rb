# From http://qiita.com/hilotter/items/fc432c33f5a012b87dca
#Resque.redis = 'localhost:6379'

# アプリ毎に異なるnamespaceを定義しておく
rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/resque.yml')
Resque.redis = resque_config[rails_env]

# Configure logger
log_path = File.join Rails.root, 'log'
config = {
  folder:     log_path,                 # destination folder
  class_name: Logger,                   # logger class name
  #class_args: [ 'daily', 1.kilobyte ],  # logger additional parameters
  level:      Logger::INFO,             # optional
  formatter:  Logger::Formatter.new,    # optional
}
Resque.logger_config = config