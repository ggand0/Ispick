class Person < ActiveRecord::Base
  belongs_to :target_word
  has_many :keywords
  has_and_belongs_to_many :titles

  #validates_uniqueness_of :name
end
