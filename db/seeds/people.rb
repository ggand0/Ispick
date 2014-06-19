require 'factory_girl'
Dir[Rails.root.join('spec/support/factories/*.rb')].each {|f| require f }

#FactoryGirl.create(:person_madoka)
#FactoryGirl.create(:person_miku)
#FactoryGirl.create(:person_maki)
FactoryGirl.create(:person_illya)

File.open("#{Rails.root}/db/seeds/characters_list").read.each_line do |line|
  tmp = line.split(',')
  person = Person.create(
    name_display: tmp[0], name: tmp[1], name_english: tmp[2], name_type: 'Character'
  )
  puts "Seeding #{person.name}"
end