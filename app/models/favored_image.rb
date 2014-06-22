class FavoredImage < ActiveRecord::Base
  belongs_to :image_board
  belongs_to :delivered_image
  has_attached_file :data,
    styles: { thumb: "300x300#", medium: "600x800>" },
    default_url: lambda { |data| data.instance.set_default_url }

  validates :src_url, uniqueness: { scope: :image_board_id }

  def set_default_url
    ActionController::Base.helpers.asset_path('default_image_thumb.png')
  end
end
