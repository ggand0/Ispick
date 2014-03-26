class Person < ActiveRecord::Base
  belongs_to :target_word
  has_many :keywords
end
