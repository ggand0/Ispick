class Tag < ActiveRecord::Base
  has_many :tags_users, dependent: :destroy
  has_many :users, :through => :tags_users

  has_many :images_tags, dependent: :destroy
  has_many :images, :through => :images_tags

  # Maybe this would be a temporary structure,
  # since we can directly redtrieve image info by favored_images.image_id
  has_many :favored_images_tags, dependent: :destroy
  has_many :favored_images, :through => :favored_images_tags

  validates_uniqueness_of :name


  # Get popular tags in the order of users_count
  # @param size [Integer]
  def self.get_popular_tags(size)
    Tag.where.not(users_count: 0).order('users_count DESC').limit(size)
  end

  # Get popular tags in the order of images_count
  # @param size [Integer]
  def self.get_tags_with_images(size)
    Tag.where.not(images_count: 0).
      order('images_count DESC').
      where(language: 'english').
      limit(size)
  end

  # Get images which refers this record.
  def get_images
    images.where.not(data_updated_at: nil).reorder('created_at DESC')
  end
end
