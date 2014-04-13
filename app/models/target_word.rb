require "#{Rails.root}/script/scrape/scrape"

class TargetWord < ActiveRecord::Base
  belongs_to :user
  has_one :person
  has_many :delivered_images, as: :targetable

  after_create :search_keyword

  def search_keyword
    query = self.person ? self.person.name : self.word
    Scrape.scrape_keyword(query)
  end
end
