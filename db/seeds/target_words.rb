=begin
# Seed independent tags(like "黒髪", "ポニーテール")
File.open("#{Rails.root}/db/seeds/words_list").read.each_line do |line|
  target_word = TargetWord.create(name: line, user_id: 1)

  puts "Seeded: #{target_word.name}"
end
=end

# Seed target_words based on all person records.
# Assume people table is already seeded.
Person.all.each do |person|
  target_word = TargetWord.create(name: person.name)
  target_word.person = person

  puts "Seeded: #{target_word.name}"
end