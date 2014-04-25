require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/deliver/deliver"
require "#{Rails.root}/app/workers/search_images"

class TargetWord < ActiveRecord::Base
  belongs_to :user
  has_one :person
  has_many :delivered_images, as: :targetable

  after_create :search_keyword
  validates :word, uniqueness: { scope: :user_id }

  def search_keyword
    Resque.enqueue(SearchImages, self.id)
  end
end
