# From http://qiita.com/hilotter/items/fc432c33f5a012b87dca
#Resque.redis = 'localhost:6379'
# アプリ毎に異なるnamespaceを定義しておく
#Resque.redis.namespace = "resque:resque_face:#{Rails.env}"
rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/resque.yml')
Resque.redis = resque_config[rails_env]