# encoding: utf-8
require "#{Rails.root}/script/restore_target_words"

namespace :util do
  desc "csvからTargetWordをrestore"
  task :target_words, [:csv_path] => :environment do |t, args|
    Util.restore_target_words(args.csv_path)
  end

  desc "Seed target_words.name_english from their person records"
  task :fill_name_english, [:csv_path] => :environment do |t, args|
    TargetWord.all.each do |target_word|
      target_word.update_attribute(:name_english, target_word.person.name_english)!
    end
  end

  task :test => :environment do
    puts "debugging something..."
    #TargetWord.all.each { |t| puts "#{t.inspect} #{t.person.inspect}" if t.nil? or t.name.empty? or t.person.nil? }
    Person.all.each do |person|
      puts person.inspect if person.titles.nil? or person.titles.empty?
    end
    Title.all.each do |title|
      puts title.inspect if title.people.nil? or title.people.empty?
    end
  end
end