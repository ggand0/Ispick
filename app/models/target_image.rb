require "#{Rails.root}/lib/utility_color"

class TargetImage < ActiveRecord::Base
  has_one :feature, as: :featurable

  has_attached_file :data,
    :use_timestamp => false

  default_scope :order => 'created_at DESC'
  paginates_per 100

  validates_presence_of :data
end
