# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

#set :output, { error: 'log/error.log', standard: 'log/cron.log'}


every 60.minutes do
  rake 'scrape:twitter[60]', output: { error: 'log/scrape_twitter_error.log', standard: 'log/scrape_twitter_cron.log' }
end

every 2.hours do
  rake 'scrape:nico[120]', output: { error: 'log/scrape_nico_error.log', standard: 'log/scrape_nico_cron.log' }
end

every 3.hours do
  rake 'scrape:tumblr[240]', output: { error: 'log/scrape_tumblr_error.log', standard: 'log/scrape_tumblr_cron.log' }
end

every 6.hours do
  #rake 'scrape:fchan'
end

# 配信システム系
every 30.minutes do
  # 指定枚数を超えたらその分Imagesから削除
  rake 'scrape:delete_excess[100000]', output: 'log/deliver.log'

  # 全てのユーザーに推薦イラストを配信
  rake 'deliver:all', output: 'log/deliver.log'
end

# パフォーマンスの関係で凍結中
every 6.hours do
  # 配信画像の統計情報を更新する
  #rake 'deliver:update'
end