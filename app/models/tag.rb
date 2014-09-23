class Tag < ActiveRecord::Base
  has_many :images_tags
  has_many :images, :through => :images_tags

  # Maybe this would be a temporary structure,
  # since we can directly redtrieve image info by favored_images.image_id
  has_many :favored_images_tags
  has_many :favored_images, :through => :favored_images_tags

  validates_uniqueness_of :name
end
