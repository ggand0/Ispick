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

  # Get popular tags in the order of users_count
  # @param size [Integer]
  def self.get_popular_tags(size)
    TargetWord.where.not(users_count: 0).order('users_count DESC').limit(size)
  end

  # Get popular tags in the order of images_count
  # @param size [Integer]
  def self.get_tags_with_images(size)
    TargetWord.where.not(images_count: 0).order('images_count DESC').limit(size)
  end

  def get_images
    images.where.not(data_updated_at: nil).reorder('created_at DESC')
  end
end
