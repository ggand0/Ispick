class ImagesTag < ActiveRecord::Base
  belongs_to :image
  belongs_to :tag, counter_cache: :images_count

  validates_uniqueness_of :tag_id, :scope => :image_id
end
