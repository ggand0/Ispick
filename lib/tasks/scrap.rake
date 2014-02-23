# encoding: utf-8
namespace :scrap do
  desc "Imagesテーブルリセット"
  task reset: :environment do
    # Imageモデルを全消去
    puts 'Deleting Image model...'
    Image.delete_all
  end

  desc "DB内Imagesテーブルをリセット後、抽出スクリプトを走らせる"
  task :rescrap_all => :environment do
    # Imageモデルを全消去
    puts 'Deleting Image model...'
    Image.delete_all

    # 対象サイトから画像抽出
    puts 'Scraping images from target websites...'
    require "#{Rails.root}/script/scrap"
    Scrap.scrap_all()

    # 全Imageに対して顔の特徴抽出処理を行う
    puts 'Extracting face feature to all images...'
    Rake::Task["feature:image_all"].invoke
  end

  desc "画像を対象webサイトから抽出する"
  task images: :environment do
    # 対象サイトから画像抽出
    puts 'Scraping images from target websites...'
    require "#{Rails.root}/script/scrap"
    Scrap.scrap_all()
  end
end
