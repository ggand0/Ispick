class Like < ActiveRecord::Base
  belongs_to :users
  validates :image_id, uniqueness: { scope: :user_id }
end
