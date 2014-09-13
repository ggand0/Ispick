class PeopleTitle < ActiveRecord::Base
  belongs_to :person
  belongs_to :title
end
