require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/deliver/deliver"
require "#{Rails.root}/app/workers/search_images"

class TargetWord < ActiveRecord::Base
  has_many :target_words_users
  has_many :users, :through => :target_words_users

  has_one :person
  has_many :delivered_images, as: :targetable

  validates_uniqueness_of :word
  #validates :word, uniqueness: { scope: :user_id }
end
