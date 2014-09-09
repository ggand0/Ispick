class Keyword < ActiveRecord::Base
  has_many :people_keywords
  has_many :people, :through => :people_keywords
  validates_uniqueness_of :name
end
