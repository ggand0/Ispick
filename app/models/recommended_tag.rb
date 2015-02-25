class RecommendedTag < ActiveRecord::Base
  has_one :tag

  has_many :tags_users, dependent: :destroy
  has_many :users, :through => :tags_users

  validates_uniqueness_of :name
end
