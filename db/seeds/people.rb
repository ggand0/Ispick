require 'factory_girl'
Dir[Rails.root.join('spec/support/factories/*.rb')].each {|f| require f }

#FactoryGirl.create(:person_madoka)
#FactoryGirl.create(:person_miku)
#FactoryGirl.create(:person_maki)
FactoryGirl.create(:person_illya)

File.open("#{Rails.root}/db/seeds/characters_list").read.each_line do |line|
  tmp = line.split(',')
  Person.create(name: tmp[0], name_english: tmp[1], name_type: 'Character')
end