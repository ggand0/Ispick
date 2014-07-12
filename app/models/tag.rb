class Tag < ActiveRecord::Base
  has_many :images_tags
  has_many :images, :through => :images_tags
  validates_uniqueness_of :name
end
