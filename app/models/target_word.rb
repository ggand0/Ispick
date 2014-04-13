require "#{Rails.root}/script/scrape/scrape"

class TargetWord < ActiveRecord::Base
  belongs_to :user
  has_one :person
  has_many :delivered_images, as: :targetable

  def after_create
    Scrape.scrape_keyword(self.word)
  end
end
