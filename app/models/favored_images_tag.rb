class FavoredImagesTag < ActiveRecord::Base
  belongs_to :favored_image
  belongs_to :tag
end
