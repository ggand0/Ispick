require "#{Rails.root}/lib/utility_color"

class TargetImage < ActiveRecord::Base
  has_one :feature, as: :featurable

  has_attached_file :data,
    :use_timestamp => false

  validates_presence_of :data
end
