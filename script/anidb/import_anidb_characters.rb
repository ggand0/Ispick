# encoding: utf-8
require 'csv'


class Import
  LIST_PATH = "#{Rails.root}/script/anidb/people_2014_main.txt"
  HASH_PATH = "#{Rails.root}/script/anidb/characters_unmatched"

  attr_accessor :people, :hash
  def initialize
    @people = Person.all
  end

  def main
    File.open(LIST_PATH, 'r') do |row|
      row.each_line.with_index do |line, count|
        next if count == 0
        attributes = line.split(/(?<!\\),/)
        #puts line.split(/[^\\,],/)         # doesn't work

        name_ja = attributes[1]
        name_en = attributes[2]
        appearances = attributes[4].split('\'')
        matched = false
        appearances.each do |appearance|
          aid = appearance.split('\,')[0].to_i
          title = Title.where(id_anidb: aid).first
          next if title.nil?

          person = Person.new(name: name_ja, name_english: name_en, name_type: 'character_anidb')
          if title and person.save
            person.titles << title
            matched = true
            break
          end
        end
        puts "unmatched character: #{name_ja}/#{name_en}" unless matched

      end
    end

  end
end
