# encoding: utf-8
require 'csv'


class Import
  LIST_PATH = "#{Rails.root}/script/anidb/people_2014_main.txt"
  HASH_PATH = "#{Rails.root}/script/anidb/characters_unmatched"

  attr_accessor :people, :hash
  def initialize
    @people = Person.all
    @hash = {}
  end

  def main
    #CSV.foreach(LIST_PATH, { :headers => false }) do |row|
      #next if $. == 1
    File.open(LIST_PATH, 'r') do |row|
      row.each_line.with_index do |line, count|
        next if count == 0
        puts attributes = line.split(/(?<!\\),/)
        #puts line.split(/[^\\,],/)

        name_ja = attributes[1]
        name_en = attributes[2]
        appearances = attributes[4].split('\'')
        appearances.each do |appearance|
          aid = appearance.split('\,')[0].to_i
          title = Title.where(id_anidb: aid).first

          person = Person.create(name: name_ja, name_english: name_en, name_type: 'character_anidb')
          if person and title
            person.titles << title
          end
        end
      end
    end

    File.open(HASH_PATH, 'w') do |f|
      @hash.each do |key, value|
        f.write("#{key}: #{value}\n")
      end
    end

  end
end

importer = Import.new
importer.main