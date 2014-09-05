class ImagesTargetWord < ActiveRecord::Base
  belongs_to :image
  belongs_to :target_word, counter_cache: :images_count

  validates_uniqueness_of, :target_word_id, :scope => :image_id
end
