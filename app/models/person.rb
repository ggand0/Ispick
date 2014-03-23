class Person < ActiveRecord::Base
  #has_many :from_friend_relations, :foreign_key => "from_user_id", :class_name => "Friend"
  #has_many :aliases, foreign_key: 'alias_id', class_name: 'Word'
  #has_many :keywords, foreign_key: 'keyword_id', class_name: 'Word'
  has_many :keywords
end
