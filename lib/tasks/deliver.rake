require "#{Rails.root}/app/services/target_images_service"
require "#{Rails.root}/script/deliver/deliver"
require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

namespace :deliver do
  # 1回の配信で、1ユーザーに対して配信する推薦イラストの数
  @MAX_DELIVER_NUM = 100
  # [MB]
  @MAX_DELIVER_SIZE = 100

  desc "Deliver images to all users"
  task all: :environment do
    User.all.each do |user|
      puts 'TEST BLOCK IS CALLED1'
      Rake::Task['deliver:user'].invoke(user.id)
      Rake::Task['deliver:user'].reenable
      #puts res
      puts 'TEST BLOCK IS CALLED2'
    end
  end

  desc "個々のユーザーにイラストを配信"
  task :user, [:user_id] =>  :environment do |t, args|
    puts 'Deliver to user_id: ' + args[:user_id].to_s
    start = Time.now
    Deliver.deliver(args[:user_id])

    puts '-----------------------------------'# 35 chars
    puts 'Elapsed time: ' + (Time.now - start).to_s
    puts 'DONE!'
  end

  desc "１つのキーワードのみに注目して画像を配信"
  task :keyword, [:user_id, :target_word_id] =>  :environment do |t, args|
    t0 = Time.now
    Deliver.deliver_keyword(args[:user_id], args[:target_word_id])
    t1 = Time.now
    puts '-----------------------------------'# 35 chars
    puts 'Elapsed time: ' + (t1-t0).to_s
    puts 'DONE!'
  end


  desc "全てのdelivered_imagesのfavoritesをupdateする"
  task :update, [:user_id] =>  :environment do |t, args|
    t0 = Time.now
    Deliver.update()
    t1 = Time.now
    puts '-----------------------------------'# 35 chars
    puts 'Elapsed time: ' + (t1-t0).to_s
    puts 'DONE!'
  end
end