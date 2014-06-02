class FavoredImage < ActiveRecord::Base
  belongs_to :image_board
  has_one :delivered_image
  has_attached_file :data

  validates :src_url, uniqueness: { scope: :user_id }
end
