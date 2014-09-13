# encoding: utf-8
require "#{Rails.root}/script/restore_target_words"

namespace :util do
  desc "csvからTargetWordをrestore"
  task :target_words, [:csv_path] => :environment do |t, args|
    Util.restore_target_words(args.csv_path)
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