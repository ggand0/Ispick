class ImageBoard < ActiveRecord::Base
  belongs_to :user
  has_many :favored_images
end
