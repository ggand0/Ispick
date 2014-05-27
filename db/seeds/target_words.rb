require 'factory_girl'
Dir[Rails.root.join('spec/support/factories/*.rb')].each {|f| require f }

Person.all.each do |person|
  target_word = TargetWord.new(word: person.name, user_id: 1)
  target_word.person = person
  target_word.save!
end