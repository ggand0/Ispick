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


# Scraping processes
every 12.hours do
  rake 'scrape:anipic[720]', output: { error: 'log/scrape_anipic_error.log', standard: 'log/scrape_anipic_cron.log' }
end

every 6.hours do
  rake 'scrape:nico[360]', output: { error: 'log/scrape_nico_error.log', standard: 'log/scrape_nico_cron.log' }
end

every 6.hours do
  rake 'scrape:tumblr[360]', output: { error: 'log/scrape_tumblr_error.log', standard: 'log/scrape_tumblr_cron.log' }
end

every 6.hours do
  #rake 'scrape:fchan'
end


# Delivery and deletion processes
every 6.hours do
  # TargetWordと同名のTagを持つImageをTargetWordと関連づける処理
  #rake 'deliver:associate', output: 'log/deliver.log'
  
  # 指定枚数を越えたらその分Imagesから画像ファイルを削除
  rake 'scrape:delete_excess_image_files[500000]', output: 'log/deliver.log'

  # 指定枚数を超えたらその分Imagesから削除
  rake 'scrape:delete_excess[1000000]', output: 'log/deliver.log'
  

end
