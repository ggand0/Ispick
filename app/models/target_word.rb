require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/deliver/deliver"
require "#{Rails.root}/app/workers/search_images"

class TargetWord < ActiveRecord::Base
  has_one :person
  has_many :delivered_images, as: :targetable

  has_many :target_words_users
  has_many :users, :through => :target_words_users

  has_many :images_target_words
  has_many :images, :through => :images_target_words

  validates_uniqueness_of :name


  def next
    TargetWord.where("id > ?", id).first
  end
end
