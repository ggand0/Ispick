class FavoredImage < ActiveRecord::Base
  belongs_to :image_board
  has_one :delivered_image
  has_attached_file :data,
    default_url: lambda { |data| data.instance.set_default_url}

  validates :src_url, uniqueness: { scope: :image_board_id }

  def set_default_url
    ActionController::Base.helpers.asset_path('default_image_thumb.png')
  end
end
