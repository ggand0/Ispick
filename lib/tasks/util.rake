# encoding: utf-8
require "#{Rails.root}/script/restore_target_words"
require "#{Rails.root}/script/anidb/anidb"
require "#{Rails.root}/script/anidb/import_anidb_characters"

namespace :util do
  desc "Refresh last 1000 thumbnails"
  task refresh_thumbs: :environment do
    count=0
    images_to_reprocess.each do |image|
      image.data.reprocess! :thumb
      break if count >= 1000
    end
  end

  desc "Restore target_words from a csv file"
  task :target_words, [:csv_path] => :environment do |t, args|
    Util.restore_target_words(args.csv_path)
  end

  desc "Seed AniDB titles"
  task :seed_anidb_titles => :environment do
    anidb = AniDB.new
    anidb.main
  end

  desc "Seed AniDB characters"
  task :seed_anidb_characters => :environment do
    importer = Import.new
    importer.main
  end

  desc "Seed target_words.name_english from their person records"
  task :fill_name_english, [:csv_path] => :environment do |t, args|
    TargetWord.all.each do |target_word|
      if target_word.name_english.nil?
        target_word.update_attribute(:name_english, target_word.person.name_english)
        puts "filled #{target_word.name_english}"
      end
    end
  end

  desc "Delete images with irrelevant words"
  task :delete_banned, [:limit] => :environment do |t, args|
    if args[:limit]
      limit = args[:limit]
    else
      limit = 1000
    end

    Image.order('created_at DESC').limit(limit).each do |image|
      if Scrape::Client.is_adult(image.tags)
        image.destroy
        puts "Deleted: #{image.id} / #{image.target_words.first.name}"
      end
    end
  end

  task :test => :environment do
    puts "debugging something..."
    Person.all.each do |person|
      puts person.inspect if person.titles.nil? or person.titles.empty?
    end
    Title.all.each do |title|
      puts title.inspect if title.people.nil? or title.people.empty?
    end
  end
end