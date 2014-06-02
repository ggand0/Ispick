# encoding: utf-8
namespace :scrape do
  @DEFAULT = 10000
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

    # http://stackoverflow.com/questions/755669/how-do-i-convert-datetime-now-to-utc-in-ruby
    old = DateTime.now.utc - 7.days   # rails onlyな書き方
    Image.where("created_at < ?", old).destroy_all

    puts 'Deleted: ' + (before_count - Image.count).to_s + ' images'
    puts 'Current image count: ' + Image.count.to_s
  end

  # @limit 最大保存数
  desc "最大保存数を超えている場合古いImageから順に削除"
  task :delete_excess, [:limit] => :environment do |t, args|
    puts 'Deleting excessed images...'

    if args[:limit]
      limit = args[:limit].to_i
    else
      limit = @DEFAULT
    end
    puts 'limit: ' + limit.to_s

    before_count = Image.count
    if Image.count > limit
      delete_num = Image.count - limit
      #puts Image.limit(delete_num).order(:created_at)
      Image.limit(delete_num).order(:created_at).destroy_all
    end

    puts 'Deleted: ' + (before_count - Image.count).to_s + ' images'
    puts 'Current image count: ' + Image.count.to_s
  end

  desc "画像を対象webサイト全てから抽出する"
  task all: :environment do
    # 対象サイトから画像抽出
    puts 'Scraping images from target websites...'
    require "#{Rails.root}/script/scrape/scrape"
    Scrape.scrape_all
  end
  desc "画像を対象webサイト全てから抽出する"
  task users: :environment do
    # 対象サイトから画像抽出
    puts 'Scraping images from target websites...'
    require "#{Rails.root}/script/scrape/scrape"
    Scrape.scrape_users
  end

  desc "タグ検索による抽出を行う"
  task keyword: :environment do
    puts 'Scraping images from target websites...'
    require "#{Rails.root}/script/scrape/scrape"
    Scrape.scrape_keyword(TargetWord.last)
  end



  # 以下、whenever用タスク
  require "#{Rails.root}/script/scrape/scrape"
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

  desc "キャラクタに関する静的なDBを構築する"
  task wiki: :environment do
    require "#{Rails.root}/script/scrape/scrape_wiki.rb"
    puts 'Scraping character names...'
    Scrape::Wiki.scrape()
  end

  # ----------------------------------
  # 以下、１つのサイトから画像抽出するタスク
  # ----------------------------------
  desc "2chから画像抽出する"
  task nichan: :environment do
    require "#{Rails.root}/script/scrape/scrape_2ch.rb"
    Scrape::Nichan.scrape()
  end

  desc "ニコ静から画像抽出する"
  task nico: :environment do
    require "#{Rails.root}/script/scrape/scrape_nico.rb"
    Scrape::Nico.scrape()
  end

  desc "ピアプロから画像抽出する"
  task piapro: :environment do
    require "#{Rails.root}/script/scrape/scrape_piapro.rb"
    Scrape::Piapro.scrape()
  end

  desc "4chanから画像抽出する"
  task fchan: :environment do
    require "#{Rails.root}/script/scrape/scrape_4chan.rb"
    Scrape::Fourchan.scrape()
  end

  desc "2chanから画像抽出する"
  task futaba: :environment do
    require "#{Rails.root}/script/scrape/scrape_futaba.rb"
    Scrape::Futaba.scrape()
  end

  desc "Twitterから画像抽出する"
  task twitter: :environment do
    require "#{Rails.root}/script/scrape/scrape_twitter.rb"
    Scrape::Twitter.scrape()
  end

  desc "Tumblrから画像抽出する"
  task tumblr: :environment do
    require "#{Rails.root}/script/scrape/scrape_tumblr.rb"
    Scrape::Tumblr.scrape()
  end

  desc "deviantARTから画像抽出する"
  task deviant: :environment do
    require "#{Rails.root}/script/scrape/scrape_deviant.rb"
    Scrape::Deviant.scrape()
  end

   desc "Giphyから画像抽出する"
  task giphy: :environment do
    require "#{Rails.root}/script/scrape/scrape_giphy.rb"
    Scrape::Giphy.scrape
  end
end
