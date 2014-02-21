# encoding: utf-8
namespace :scrap do
  desc "DBをリセット後、抽出スクリプトを走らせる"

  task :rescrap_all => :environment do
    #Rake::Task["db:reset"].invoke  # 全DBリセット
    Image.delete_all                # Imageモデルを全消去

    require "#{Rails.root}/script/scrap"
    Scrap.scrap_all()
  end
end
