require "#{Rails.root}/lib/utility_color"

class TargetImage < ActiveRecord::Base
  has_one :feature, as: :featurable
  belongs_to :user
  default_scope { order('created_at DESC') }
  paginates_per 100

  has_attached_file :data,
    use_timestamp: false

  validates_presence_of :data
end
