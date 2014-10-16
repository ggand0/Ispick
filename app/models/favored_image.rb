class FavoredImage < ActiveRecord::Base
  has_many :favored_images_tags, dependent: :destroy
  has_many :tags, :through => :favored_images_tags
  belongs_to :image_board
  belongs_to :image

  has_attached_file :data,
    styles: { original: "600x800>", thumb: "300>" },
    default_url: lambda { |data| data.instance.set_default_url }
  validates :src_url, uniqueness: { scope: :image_board_id }

  def set_default_url
    ActionController::Base.helpers.asset_path('default_image_thumb.png')
  end
end
