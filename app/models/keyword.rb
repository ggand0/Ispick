class Keyword < ActiveRecord::Base
  has_and_belongs_to_many :people, :join_table => 'people_keywords'
  validates_uniqueness_of :word
end
