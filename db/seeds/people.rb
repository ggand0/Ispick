require 'factory_girl'
Dir[Rails.root.join('spec/support/factories/*.rb')].each {|f| require f }

FactoryGirl.create(:person_madoka)
FactoryGirl.create(:person_miku)
FactoryGirl.create(:person_maki)
FactoryGirl.create(:person_illya)