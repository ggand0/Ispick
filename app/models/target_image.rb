class TargetImage < ActiveRecord::Base
  has_attached_file :data

  validates_presence_of :data

  def debug
    return 1
  end
end
