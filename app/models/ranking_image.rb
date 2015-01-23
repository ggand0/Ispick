class RankingImage < ActiveRecord::Base

  def self.get_images
    rankings = RankingImage.all.map { |ranking| ranking.image_id }

    images = Image.where(id: rankings)
    images
  end
end
