class TagsUser < ActiveRecord::Base
  belongs_to :tag, counter_cache: :users_count
  belongs_to :user

  validates :tag_id, uniqueness: { scope: :user_id }
  validates :user_id, uniqueness: { scope: :tag_id }
end
