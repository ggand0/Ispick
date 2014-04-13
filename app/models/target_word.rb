require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/deliver/deliver"
require "#{Rails.root}/app/workers/search_images"

class TargetWord < ActiveRecord::Base
  belongs_to :user
  has_one :person
  has_many :delivered_images, as: :targetable

  after_create :search_keyword

  def search_keyword
    #query = self.person ? self.person.name : self.word
    #Scrape.scrape_keyword(query)
    #Deliver.deliver_keyword(self.user_id, self.id)
    Resque.enqueue(SearchImages, self.id)
  end
end
