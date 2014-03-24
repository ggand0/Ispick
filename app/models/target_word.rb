class TargetWord < ActiveRecord::Base
  belongs_to :user
  has_one :person
end
