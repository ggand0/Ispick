class PeopleKeyword < ActiveRecord::Base
  #self.table_name = 'people_keywords'
  belongs_to :person
  belongs_to :keyword
end
