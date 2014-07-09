# encoding: utf-8
require "#{Rails.root}/script/scrape/scrape"

namespace :scrape do
  @DEFAULT = 10000

  # ----------------------------------
  # General
  # ----------------------------------
  desc "指定された時期より古いImageを削除"
  task delete_old: :environment do
    puts 'Deleting old images...'
    before_count = Image.count

    # http://stackoverflow.com/questions/755669/how-do-i-convert-datetime-now-to-utc-in-ruby
    old = DateTime.now.utc - 7.days                 # rails onlyな書き方
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
    puts 'Scraping images from target websites...'
    Scrape.scrape_all
  end

  desc "画像を対象webサイト全てから抽出する"
  task users: :environment do
    puts 'Scraping images from target websites...'
    Scrape.scrape_users
  end

  desc "タグ検索による抽出を行う"
  task keyword: :environment do
    puts 'Scraping images from target websites...'
    Scrape.scrape_keyword(TargetWord.last)
  end

  desc "dataがnilのレコードにsrc_urlから再DLさせる"
  task redownload: :environment do
    puts 'Downloading for images with nil data...'
    Scrape.redownload
  end


  # ----------------------------------
  # 特定のサイトから画像抽出するタスク
  # ----------------------------------
  require "#{Rails.root}/script/scrape/scrape_nico.rb"
  require "#{Rails.root}/script/scrape/scrape_2ch.rb"
  require "#{Rails.root}/script/scrape/scrape_futaba.rb"
  require "#{Rails.root}/script/scrape/scrape_piapro.rb"
  require "#{Rails.root}/script/scrape/scrape_4chan.rb"
  require "#{Rails.root}/script/scrape/scrape_twitter.rb"
  require "#{Rails.root}/script/scrape/scrape_tumblr.rb"
  require "#{Rails.root}/script/scrape/scrape_deviant.rb"
  require "#{Rails.root}/script/scrape/scrape_giphy.rb"
  require "#{Rails.root}/script/scrape/scrape_matome.rb"
  require "#{Rails.root}/script/scrape/scrape_wiki.rb"

  desc "キャラクタに関する静的なDBを構築する"
    task wiki: :environment do
      puts 'Scraping character names...'
      Scrape::Wiki.scrape
    end

  desc "2chから画像抽出する"
  task nichan: :environment do

    Scrape::Nichan.scrape
  end

  desc "ニコ静から画像抽出する"
  task :nico, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 120 : args[:interval]
    Scrape::Nico.scrape(interval.to_i, false)
  end

  desc "ピアプロから画像抽出する"
  task piapro: :environment do
    Scrape::Piapro.scrape
  end

  desc "4chanから画像抽出する"
  task fchan: :environment do

    Scrape::Fourchan.scrape
  end

  desc "2chanから画像抽出する"
  task futaba: :environment do
    Scrape::Futaba.scrape
  end

  desc "Twitterから画像抽出する"
  task :twitter, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 60 : args[:interval]
    Scrape::Twitter.scrape(interval.to_i, false)
  end

  desc "Tumblrから画像抽出する"
  task :tumblr, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 240 : args[:interval]
    Scrape::Tumblr.scrape(interval.to_i, false)
  end

  desc "deviantARTから画像抽出する"
  task deviant: :environment do
    Scrape::Deviant.scrape
  end

  desc "Giphyから画像抽出する"
  task giphy: :environment do
    Scrape::Giphy.scrape
  end

  desc "まとめサイトから画像抽出する"
  task matome: :environment do
    Scrape::Matome.scrape
  end
end
