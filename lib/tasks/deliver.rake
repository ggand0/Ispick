require "#{Rails.root}/app/services/target_images_service"
require "#{Rails.root}/script/deliver/deliver"
require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

namespace :deliver do
  # 1回の配信で、1ユーザーに対して配信する推薦イラストの数
  @MAX_DELIVER_NUM = 100
  # [MB]
  @MAX_DELIVER_SIZE = 100*1024*1024

  desc "Deliver images to all users"
  task all: :environment do
    User.all.each do |user|
      Rake::Task['deliver:user'].invoke user.id
    end
  end

  desc "個々のユーザーにイラストを配信"
  task :user, [:user_id] =>  :environment do |t, args|
    t0 = Time.now
    count = 0
    delivered = []

    user = User.find(args[:user_id])
    count_all = user.target_images.length
    user.target_images.each do |t|
      Deliver.deliver_from_target(user, t, count_all, count)
      count += 1
    end

    t1 = Time.now
    puts 'Elapsed time: ' + (t1-t0).to_s
    puts 'DONE!'
  end
end