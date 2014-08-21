require "#{Rails.root}/app/services/target_images_service"
require "#{Rails.root}/script/deliver/deliver"
require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

namespace :deliver do
  @MAX_DELIVER_NUM = 100  # 1回の配信で、1ユーザーに対して配信する推薦イラストの数
  @MAX_DELIVER_SIZE = 100 # 1回の配信で、1ユーザーに対して配信するイラストのサイズ[MB]

  desc "Associate all target_words with images"
  task associate: :environment do
    start = Time.now
    Deliver::Words.associate_words_with_images
    puts "Elapsed time: #{(Time.now - start).to_s}"
    puts 'DONE!'
  end

  desc "Associate all target_words with images"
  task associate!: :environment do
    start = Time.now
    Deliver::Words.associate_words_with_images!
    puts "Elapsed time: #{(Time.now - start).to_s}"
    puts 'DONE!'
  end

  # ===========
  #  Old tasks
  # ===========
  desc "Deliver images to all users"
  task all: :environment do
    puts '-----------------------------------'
    puts "Delivering: start=#{DateTime.now}"

    User.all.each do |user|
      Rake::Task['deliver:user'].invoke(user.id)
      Rake::Task['deliver:user'].reenable
    end
  end

  desc "個々のユーザーにイラストを配信"
  task :user, [:user_id] =>  :environment do |t, args|
    puts "Delivering to user_id: #{args[:user_id].to_s}"
    start = Time.now
    Deliver.deliver(args[:user_id])

    puts '-----------------------------------'
    puts "Elapsed time: #{(Time.now - start).to_s}"
    puts 'DONE!'
  end

  desc "１つのキーワードのみに注目して画像を配信"
  task :keyword, [:user_id, :target_word_id] =>  :environment do |t, args|
    start = Time.now
    Deliver.deliver_keyword(args[:user_id], args[:target_word_id])

    puts '-----------------------------------'
    puts "Elapsed time: #{(Time.now - start).to_s}"
    puts 'DONE!'
  end


  desc "全てのdelivered_imagesのfavoritesをupdateする"
  task :update, [:user_id] =>  :environment do |t, args|
    start = Time.now
    Deliver.update

    puts '-----------------------------------'
    puts "Elapsed time: #{(Time.now - start).to_s}"
    puts 'DONE!'
  end
end