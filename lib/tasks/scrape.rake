# encoding: utf-8
namespace :scrape do
  desc "Imagesテーブルリセット"
  task reset: :environment do
    # Imageモデルを全消去
    puts 'Deleting Image model...'
    Image.delete_all
  end

  desc "DB内Imagesテーブルをリセット後、抽出スクリプトを走らせる"
  task :rescrape_all => :environment do
    # Imageモデルを全消去
    puts 'Deleting Image model...'
    Image.delete_all

    # 対象サイトから画像抽出
    puts 'Scraping images from target websites...'
    require "#{Rails.root}/script/scrap"
    Scrape.scrape_all()

    # 全Imageに対して顔の特徴抽出処理を行う
    puts 'Extracting face feature to all images...'
    Rake::Task["feature:image_all"].invoke
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
