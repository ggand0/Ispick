class RecommendedTagsUser < ActiveRecord::Base
  belongs_to :recommended_tag
  belongs_to :user

  validates :recommended_tag_id, uniqueness: { scope: :user_id }
  validates :user_id, uniqueness: { scope: :recommended_tag_id }
end
