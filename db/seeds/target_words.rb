require 'factory_girl'
Dir[Rails.root.join('spec/support/factories/*.rb')].each {|f| require f }


=begin
# キャラクタ名と関連づけられたタグのseed
Person.all.each do |person|
  target_word = TargetWord.new(word: person.name, user_id: 1)
  target_word.person = person
  target_word.save!
end
=end

# 独立したタグのseed
File.open("#{Rails.root}/db/seeds/words_list").read.each_line do |line|
  # タグ登録直後の配信によって負荷が掛かるのを避けるためにcallbackをskipする
  TargetWord.skip_callback(:create, :after, :search_keyword)
  target_word = TargetWord.create(word: line, user_id: 1)
  TargetWord.set_callback(:create, :after, :search_keyword)

  puts "Seeding #{target_word.word}"
end