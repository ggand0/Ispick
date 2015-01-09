# encoding: utf-8
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_nico.rb"
require "#{Rails.root}/script/scrape/scrape_piapro.rb"
require "#{Rails.root}/script/scrape/scrape_4chan.rb"
require "#{Rails.root}/script/scrape/scrape_tumblr.rb"
require "#{Rails.root}/script/scrape/scrape_deviant.rb"
require "#{Rails.root}/script/scrape/scrape_giphy.rb"
require "#{Rails.root}/script/scrape/scrape_wiki.rb"
require "#{Rails.root}/script/scrape/scrape_tags.rb"
require "#{Rails.root}/script/scrape/scrape_anipic.rb"
require "#{Rails.root}/script/scrape/scrape_shushu.rb"
require "#{Rails.root}/script/scrape/scrape_zerochan.rb"

namespace :scrape do
  @DEFAULT_MN = 10000
  @DEFAULT_MO = 7

  # ==================================
  #           General tasks
  # ==================================

  # 指定された時期より古いImageを削除
  desc "Delete images older than a certain date"
  task :delete_old, [:limit] => :environment do |t, args|
    puts 'Deleting old images...'

    if args[:limit]
      limit = args[:limit].to_i
    else
      limit = @DEFAULT_MO
    end

    before_count = Image.count

    # ref: http://stackoverflow.com/questions/755669/how-do-i-convert-datetime-now-to-utc-in-ruby
    old = DateTime.now.utc - limit.days
    Image.where("created_at < ?", old).destroy_all

    puts "Deleted: #{(before_count - Image.count).to_s} images"
    puts "Current image count: #{Image.count.to_s}"
  end

  # @params limit [Integer] 最大保存数
  # 最大保存数を超えている場合古いImageから順に削除、削除したレコード情報はold_record.txtにエクスポートする
  desc "Delete images if its the count of all images exceeds the limit"
  task :delete_excess, [:limit] => :environment do |t, args|
    puts 'Deleting excessed images...'

    if args[:limit]
      limit = args[:limit].to_i
    else
      limit = @DEFAULT_MN
    end
    puts "limit: #{limit.to_s}"

    before_count = Image.count
    if Image.count > limit
      delete_num = Image.count - limit

      # recordを削除する前にtxtファイルにエクスポートする
=begin
      io = File.open("#{Rails.root}/log/old_record.txt","a")
      Image.reorder(:created_at).limit(delete_num).each do |image|
        str=""
        image.attributes.keys.each do |key|
          if !image[key].nil?
            str = str + key.to_s + ":\"" + image[key].to_s + "\","
          else
            str = str + key.to_s + ":\"nil\","
          end
        end
        str = str + "tags:\""
        image.tags.each do |tag|
          str = str + tag.name + "|"
        end
        str = str+"\""
        io.puts(str)
      end
      io.close
=end

      Image.reorder(:created_at).limit(delete_num).destroy_all
    end

    puts "Deleted: #{(before_count - Image.count).to_s} images"
    puts "Current image count: #{Image.count.to_s}"
  end

  # @params limit [Integer] 最大保存数
  # 最大保存数を超えている場合、古いImageから順に画像ファイルだけを削除
  desc "Delete images if its the count of all images exceeds the limit"
  task :delete_excess_image_files, [:limit] => :environment do |t, args|
    puts "Deleting excessed image's files..."

    if args[:limit]
      limit = args[:limit].to_i
    else
      limit = @DEFAULT_MN
    end
    puts "limit: #{limit.to_s}"

    # 画像を持つレコードの数
    before_count = Image.where.not(data_file_size:nil).count
    if before_count > limit
      delete_num = before_count - limit
      Image.where.not(data_file_size:nil).reorder(:created_at).limit(delete_num).each do |image|
        image.destroy_image_files
      end
    end

    puts "Deleted: #{(before_count - Image.where.not(data_file_size:nil).count).to_s} image's files"
    puts "Current image count: #{Image.count.to_s}"
    puts "Number of images with not nil data: #{Image.where.not(data_file_size:nil).count}"
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

  # dataがnilのレコードにsrc_urlから再DLさせる
  desc "Redownload an image data which has nil src_url attribute"
  task redownload: :environment do
    puts 'Downloading for images with nil data...'
    Scrape.redownload
  end

  # people関連テーブルを完全に抹消する（デバッグ時に使用）
  desc "Delete all people related tables completely"
  task delete_people: :environment do
    puts 'Deleting all people related tables...'
    Person.delete_all
    Title.delete_all
    Keyword.delete_all
    PeopleKeyword.delete_all
    PeopleTitle.delete_all
  end

  # images, tags, target_wordsのレコード、画像ファイルを完全に消す
  desc "Delete images and target_words related tables completely"
  task delete_all: :environment do
    puts 'Deleting all images / target_words related tables and image files...'

    # First, delete images and its files
    Image.delete_all
    require 'fileutils'
    begin
      FileUtils.rm_rf("#{Rails.root}/public/system/images")
    rescue => e
      puts "Failed to delete image files.\nPerhaps its already deleted."
    end

    # Then, delete other tables
    Tag.delete_all
    ImagesTag.delete_all
    TargetWord.delete_all
    TargetWordsUser.delete_all
  end


  # =======================================
  #  Tasks to scrape on the specific sites
  # =======================================
  desc "キャラクタに関する静的なDBを構築する"
  task wiki: :environment do
    puts 'Scraping character names...'
    Scrape::Wiki.scrape_all
  end

  desc "キャラクタに関する静的なDBを構築する"
  task wiki_titles: :environment do
    puts 'Scraping anime titles...'
    Scrape::Wiki.scrape_titles
  end

  desc "キャラクタ名をAnime-picturesから抽出する"
  task tags: :environment do
    puts 'Scraping character names from anime-pictures.net...'
    Scrape::Tags.scrape
  end

  desc "Create TargetWord records for research"
  task people0: :environment do
    require 'csv'

    csv_text = File.read "#{Rails.root}/db/seeds/people0.csv"
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      Person.create!(row.to_hash)
    end
  end


  desc "ニコ静から画像抽出する"
  task :nico, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 120 : args[:interval]
    Scrape::Nico.new.scrape(interval.to_i)
  end

  desc "ピアプロから画像抽出する"
  task piapro: :environment do
    Scrape::Piapro.scrape
  end

  desc "4chanから画像抽出する"
  task fchan: :environment do

    Scrape::Fourchan.scrape
  end

  desc "Tumblrから画像抽出する"
  task :tumblr, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 240 : args[:interval]
    Scrape::Tumblr.new.scrape(interval.to_i)
  end

  desc "deviantARTから画像抽出する"
  task deviant: :environment do
    Scrape::Deviant.scrape
  end

  # Giphyから画像抽出する
  desc "Scrape images from Giphy"
  task :giphy, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 720 : args[:interval]
    Scrape::Giphy.new.scrape(interval.to_i)
  end

  # Anime pictures and wallpapersから画像抽出する
  desc "Scrape images from 'Anime pictures and wallpapers'"
  task :anipic, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 240 : args[:interval]
    Scrape::Anipic.new.scrape(interval.to_i)
  end

  desc "Scrape images from 'Anime pictures and wallpapers'"
  task :anipic_tag, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 240 : args[:interval]
    Scrape::Anipic.new.scrape_tag(interval.to_i)
  end

  # Anime pictures and wallpapersから画像抽出する
  desc "Scrape images from 'Anime pictures and wallpapers'"
  task :anipic_tag, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 240 : args[:interval]
    Scrape::Anipic.new.scrape_tag(interval.to_i)
  end

  # shushuから画像を抽出する
  desc "Scrape images from 'Shushu'"
  task :shushu, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 240 : args[:interval]
    Scrape::Shushu.new.scrape(interval.to_i)
  end

  # zerochanから画像を抽出する
  desc "Scrape images from 'zerochan'"
  task :zerochan, [:interval] => :environment do |t, args|
    interval = args[:interval].nil? ? 240 : args[:interval]
    Scrape::Zerochan.new.scrape(interval.to_i)
  end

end
