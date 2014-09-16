class ImageBoard < ActiveRecord::Base
  belongs_to :user
  has_many :favored_images

  validates_uniqueness_of :name, :scope => :user_id


  # Calculates the file size of a favored_image relation.
  # @params favored_images [ActiveRecord::AssociationRelation]
  # @return [Integer] Total file size[bytes] of the relation
  def get_total_size
    total_size = 0
    self.favored_images.each do |n|
      # まだコピーされていない(生存中のImageを参照している)
      if n.image_id
        image = Image.find(n.image_id)
        total_size += image.data.size
      # 既にコピーされている(ソース元のImageは削除されている)
      else
        total_size += n.data.size
      end
    end
    total_size
  end
end
