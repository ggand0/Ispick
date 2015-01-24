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


# ==================
#   Scraping tasks
# ==================
every 12.hours do
  rake 'scrape:anipic', output: { error: 'log/scrape_anipic_error.log', standard: 'log/scrape_anipic_cron.log' }
end

every 6.hours do
  rake 'scrape:pixiv', output: { error: 'log/scrape_pixiv_error.log', standard: 'log/scrape_pixiv_cron.log' }
end

every 3.hours do
  rake 'scrape:nico', output: { error: 'log/scrape_nico_error.log', standard: 'log/scrape_nico_cron.log' }
end

every 3.hours do
  rake 'scrape:shushu', output: { error: 'log/scrape_shushu_error.log', standard: 'log/scrape_shushu_cron.log' }
end

every 3.hours do
  rake 'scrape:zerochan', output: { error: 'log/scrape_zerochan_error.log', standard: 'log/scrape_zerochan_cron.log' }
end

every 2.hours do
  rake 'scrape:deviant', output: { error: 'log/scrape_deviant_error.log', standard: 'log/scrape_deviant_cron.log' }
end

#every 6.hours do
#  rake 'scrape:tumblr[360]', output: { error: 'log/scrape_tumblr_error.log', standard: 'log/scrape_tumblr_cron.log' }
#end


# ==================
#    System tasks
# ==================
every 6.hours do
  # 指定枚数を越えたらその分Imagesから画像ファイルを削除
  # If the number of records exceeds the limit, delete the image files of excess records
  rake 'scrape:delete_excess_image_files[500000]', output: 'log/system.log'

  # 指定枚数を超えたらその分Imagesから削除
  # If the number of records exceeds the limit, delete the records themselves
  rake 'scrape:delete_excess[1000000]', output: 'log/system.log'
end

# Update ranking records and create a 'daily image' record
every 1.day, :at => '6:00 pm' do
  rake 'system:update_ranking'
end


