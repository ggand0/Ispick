# From http://qiita.com/hilotter/items/fc432c33f5a012b87dca
Resque.redis = 'localhost:6379'
# アプリ毎に異なるnamespaceを定義しておく
Resque.redis.namespace = "resque:resque_face:#{Rails.env}"