require "#{Rails.root}/lib/utility_color"

class TargetImage < ActiveRecord::Base
  has_one :feature, as: :featurable
  has_many :delivered_images, as: :targetable
  belongs_to :user
  default_scope { order('created_at DESC') }
  paginates_per 100

  has_attached_file :data,
    styles: {
      thumb: "100x100#",
      small: "150x150>",
      medium: "200x200" },
    use_timestamp: false

  validates_presence_of :data
end
