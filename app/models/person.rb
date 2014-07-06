class Person < ActiveRecord::Base
  belongs_to :target_word
  has_and_belongs_to_many :keywords, :join_table => 'people_keywords'
  has_and_belongs_to_many :titles

  validates_uniqueness_of :name
end
