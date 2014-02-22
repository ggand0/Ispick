require "#{Rails.root}/lib/utility_color"

class TargetImage < ActiveRecord::Base
  has_attached_file :data
    #:url => '/system/:class/:attachment/:filename',
    #:path => ':rails_root/public/system/:class/:attachment/:filename'

  validates_presence_of :data
end
