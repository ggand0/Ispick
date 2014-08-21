class ImagesTargetWord < ActiveRecord::Base
  belongs_to :image
  belongs_to :target_word
end
