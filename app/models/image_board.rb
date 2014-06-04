class ImageBoard < ActiveRecord::Base
  belongs_to :user
  has_many :favored_images

  validates_uniqueness_of :name, :scope => :user_id
end
