=begin
# Seed independent tags(like "黒髪", "ポニーテール")
File.open("#{Rails.root}/db/seeds/words_list").read.each_line do |line|
  target_word = TargetWord.create(word: line, user_id: 1)

  puts "Seeded: #{target_word.word}"
end
=end

# Seed target_words based on all person records.
# Assume people table is already seeded.
Person.all.each do |person|
  target_word = TargetWord.create(word: person.name, user_id: 1)
  target_word.person = person

  puts "Seeded: #{target_word.word}"
end