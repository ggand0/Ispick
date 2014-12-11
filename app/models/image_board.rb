class ImageBoard < ActiveRecord::Base
  belongs_to :user
  has_many :favored_images, dependent: :destroy

  validates_uniqueness_of :name, :scope => :user_id


  # Calculates the file size of the favored_images relation.
  # @params favored_images [ActiveRecord::AssociationRelation]
  # @return [Integer] Total file size[bytes] of the relation
  def get_total_size
    total_size = 0
    self.favored_images.each do |favored_image|

      # When the source Image record is still alive:
      # ソース元のImageが生きている時
      if favored_image.image_id
        begin
          image = Image.find(favored_image.image_id)
          total_size += image.data.size
        rescue ActiveRecord::RecordNotFound => e
          total_size += favored_image.data.size
          next
        end
      # When the source Image record is dead or deleted:
      # ソース元のImageは削除されている時
      else
        total_size += favored_image.data.size
      end
    end

    total_size
  end
end
