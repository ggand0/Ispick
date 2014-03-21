class FavoredImage < ActiveRecord::Base
  belongs_to :user

  has_attached_file :data

  validates_uniqueness_of :src_url
end
