require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/deliver/deliver"
require "#{Rails.root}/app/workers/search_images"

class TargetWord < ActiveRecord::Base
  has_one :person

  has_many :images_target_words, dependent: :destroy
  has_many :images, :through => :images_target_words

  validates_uniqueness_of :name

  # 自分の次にidが小さいレコードを返す。クロール時に使用
  # Return the record that has the smalledst id value next to self.
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

  # Get images which refers this record.
  def get_images
    images.where.not(data_updated_at: nil).reorder('created_at DESC')
  end

  # Get name for displaying
  def get_name(language)
    if language == 'ja'
      name ? name : name_english
    else
      name_english
    end
  end
end
