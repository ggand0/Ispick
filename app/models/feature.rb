class Feature < ActiveRecord::Base
  belongs_to :featurable, polymorphic: true
end
