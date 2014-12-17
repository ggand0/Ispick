require "#{Rails.root}/lib/utility_color"

class TargetImage < ActiveRecord::Base
  belongs_to :user
  has_one :feature, as: :featurable

  default_scope { order('created_at DESC') }
  paginates_per 100

  has_attached_file :data,
    styles: {
      thumb: "300x",
      medium: "600x800>"
    },
    use_timestamp: false

  validates_presence_of :data
  validates_attachment_size :data, less_than: 5.megabytes
  validates_attachment_content_type :data, content_type: /^image\/(jpg|jpeg|pjpeg|png|x-png|gif)$/


  def get_similar_convnet_images(limit=1000)
    images = Image.all.limit(limit)
    similar = []
    my_feature = JSON.parse(self.feature.convnet_feature)

    images.each do |image|
      image_feature = JSON.parse(image.feature.convnet_feature)
      
    end
  end

  def self.get_distance(v1, v2)
    sum = 0
    (0..v1.count-1).each do |index|
      sum += (v1[index]-v2[index])*(v1[index]-v2[index])
    end
    Math.sqrt(sum)
  end

end
