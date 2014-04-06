class TargetWord < ActiveRecord::Base
  belongs_to :user
  has_one :person
  has_many :delivered_images, as: :targetable
end
