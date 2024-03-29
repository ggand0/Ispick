=begin
# Seed person records from the text file.
File.open("#{Rails.root}/db/seeds/characters_list").read.each_line do |line|
  tmp = line.split(',')
  person = Person.create(
    name_display: tmp[0], name: tmp[1], name_english: tmp[2], name_type: 'Character'
  )
  puts "Seeded: #{person.name}"
end
=end

# Seed person records from the list that is created by scraping AniDB.
require "#{Rails.root}/script/anidb/import_anidb_characters"
importer = Import.new
importer.main