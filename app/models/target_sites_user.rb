class TargetSitesUser < ActiveRecord::Base
  belongs_to :target_site
  belongs_to :user

  validates :target_site_id, uniqueness: { scope: :user_id }
  validates :user_id, uniqueness: { scope: :target_site_id }
end
