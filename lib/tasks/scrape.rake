# encoding: utf-8
namespace :scrape do
  desc "Imagesテーブルリセット"
  task reset: :environment do
    # Imageモデルを全消去
    puts 'Deleting all images...'
    Image.delete_all
  end

  desc "指定された時期より古いImageを削除"
  task delete_old: :environment do
    puts 'Deleting old images...'
    before_count = Image.count
    Image.where("created_at < ?", 1.week.ago).destroy_all

    puts 'Deleted: ' + (before_count - Image.count).to_s + ' images'
    puts 'Current image count: ' + Image.count.to_s
  end

  # @limit 最大保存数
  desc "最大保存数を超えている場合古いImageから順に削除"
  task :delete_excess, [:limit] => :environment do |t, args|
    puts 'Deleting excessed images...'
    before_count = Image.count
    if Image.count > args[:limit]
      delete_num = Image.count - args[:limit]
      puts Image.limit(delete_num).order(:created_at)
      Image.limit(delete_num).order(:created_at).destroy_all
    end

    puts 'Deleted: ' + (before_count - Image.count).to_s + ' images'
    puts 'Current image count: ' + Image.count.to_s
  end

  desc "DB内Imagesテーブルをリセット後、抽出スクリプトを走らせる"
  task :rescrape_all => :environment do
    # Imageモデルを全消去
    puts 'Deleting Image model...'
    Image.delete_all

    # 対象サイトから画像抽出
    puts 'Scraping images from target websites...'
    require "#{Rails.root}/script/scrape"
    Scrape.scrape_all()

    # 全Imageに対して顔の特徴抽出処理を行う
    puts 'Extracting face feature to all images...'
    Rake::Task['feature:face_images'].invoke
  end

  desc "画像を対象webサイト全てから抽出する"
  task images: :environment do
    # 対象サイトから画像抽出
    puts 'Scraping images from target websites...'
    require "#{Rails.root}/script/scrape"
    Scrape.scrape_all()
  end


  # 以下、whenever用タスク
  require "#{Rails.root}/script/scrape"
  desc "every 5 min"
  task min5: :environment do
    puts 'Scraping images from target websites...'
    Scrape.scrape_5min()
  end

  desc "every 15 min"
  task min15: :environment do
    puts 'Scraping images from target websites...'
    Scrape.scrape_15min()
  end

  desc "every 30 min"
  task min30: :environment do
    puts 'Scraping images from target websites...'
    Scrape.scrape_30min()
  end

  desc "every 60 min"
  task min60: :environment do
    puts 'Scraping images from target websites...'
    Scrape.scrape_60min()
  end
end
