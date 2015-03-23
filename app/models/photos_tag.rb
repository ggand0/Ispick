class PhotosTag < ActiveRecord::Base
  belongs_to :photo
  belongs_to :tag

  validates_uniqueness_of :tag_id, :scope => :photo_id
end
