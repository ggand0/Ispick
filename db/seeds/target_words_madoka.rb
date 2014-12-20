=begin
# Seed independent tags(like "黒髪", "ポニーテール")
File.open("#{Rails.root}/db/seeds/words_list").read.each_line do |line|
  target_word = TargetWord.create(name: line, user_id: 1)

  puts "Seeded: #{target_word.name}"
end
=end

# Seed target_words based on all person records.
# Assume people table is already seeded.
madoka = Person.create(name: 'Madoka Kaname', name_english: 'Madoka Kaname', name_roman: 'Kaname Madoka')
target_madoka = TargetWord.create(name: 'Madoka Kaname', name_english: 'Madoka Kaname')
target_madoka.person = madoka