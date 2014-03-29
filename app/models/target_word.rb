class TargetWord < ActiveRecord::Base
  belongs_to :user
  has_one :person
  has_one :delivered_image, as: :targetable
end
