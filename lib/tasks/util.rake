# encoding: utf-8
require "#{Rails.root}/script/restore_target_words"
require "#{Rails.root}/script/anidb/anidb"
require "#{Rails.root}/script/anidb/import_anidb_characters"

namespace :util do
  desc "Redownload first n thumbnails"
  task :redownload_all, [:limit]=> :environment do |t, args|
    count=0
    if args[:limit]
      limit = args[:limit].to_i
    else
      limit = 1000
    end
    Image.limit(limit).each do |image|
      next if image.data_updated_at.nil?
      begin
        image.data.destroy
        image.image_from_url(image.src_url)
        image.save!
        puts "#{image.id} thumb redownloaded."
      rescue => e
        puts e
        puts "#{image.id} thumb redownload failed."
      end
    end
  end

  desc "Redownload the thumbnail of an Image record"
  task :redownload, [:id]=> :environment do |t, args|
    count=0
    if args[:id]
      id = args[:id].to_i
    else
      return
    end
    image = Image.find(id)
    begin
      image.data.destroy
      image.image_from_url(image.src_url)
      image.save!
      puts "#{image.id} thumb redownloaded."
    rescue => e
      puts e
      puts "#{image.id} thumb redownload failed."
    end
  end

  desc "Refresh last n thumbnails"
  task :refresh_thumbs, [:limit]=> :environment do |t, args|
    count=0
    if args[:limit]
      limit = args[:limit].to_i
    else
      limit = 1000
    end
    Image.limit(limit).each do |image|
      next if image.data_updated_at.nil?
      begin
        image.data.reprocess! :thumb
        puts "#{image.id} thumb refreshed."
      rescue => e
        puts e
        puts "#{image.id} thumb refresh failed."
      end
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

  desc "Delete images with irrelevant or banned words"
  task :delete_banned, [:limit] => :environment do |t, args|
    if args[:limit]
      limit = args[:limit]
    else
      limit = 1000
    end

    Image.order('created_at DESC').limit(limit).each do |image|
      if Scrape::Client.check_banned(image)
        image.destroy
        puts "Deleted: #{image.id}"
      end
    end
  end

  desc "Delete all Tumblr images"
  task delete_tumblr: :environment do
    Image.destroy_all(site_name: 'tumblr')

    puts "DONE!"
  end

  desc "Delete tags that aren't associated with any images"
  task delete_tags: :environment do
    count = 0
    Tag.all.each do |tag|
      if tag.images.count == 0
        tag.destroy
        puts "Deleted: #{tag.id}"
        count += 1
      end
    end

    puts "Number of tags destroyed: #{count}"
  end

  desc "Reset counter cache of tags table"
  task reset_tag_counter: :environment do
    count = 0
    Tag.all.each_with_index do |tag, count|
      Tag.reset_counters(tag.id, :images)
      puts "#{count} / #{Tag.count}" if count % 1000 == 0
    end
    puts "counter cache reset has been completed!"
  end

  desc "Reset counter cache of tags table"
  task delete_tag_counter: :environment do
    # =================================================================
    #  Make sure you've already run the "util:reset_tag_counter" task!
    # =================================================================
    count = 0
    Tag.destroy_all(images_count: 0)
    puts "DONE!"
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