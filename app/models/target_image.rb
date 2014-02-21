class TargetImage < ActiveRecord::Base
  has_attached_file :data

  validates_presence_of :data
end
