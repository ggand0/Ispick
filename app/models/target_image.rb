require "#{Rails.root}/lib/utility_color"

class TargetImage < ActiveRecord::Base
  belongs_to :user
  has_one :feature, as: :featurable

  default_scope { order('created_at DESC') }
  paginates_per 100

  has_attached_file :data,
    styles: {
      small: "150x150",
      thumb: "300x",
      medium: "600x800>"
    },
    use_timestamp: false
  after_post_process :save_image_dimensions

  validates_presence_of :data
  validates_attachment_size :data, less_than: 5.megabytes
  validates_attachment_content_type :data, content_type: /^image\/(jpg|jpeg|pjpeg|png|x-png|gif)$/

  def save_image_dimensions
    geo = Paperclip::Geometry.from_file(data.queued_for_write[:thumb])
    self.width = geo.width
    self.height = geo.height
  end


  def get_similar_convnet_images(limit=1000)
    images = Image.all.limit(limit)
    similar = []
    my_feature = JSON.parse(self.feature.convnet_feature)['features']
    my_feature = my_feature.map(&:to_i)

    images.each do |image|
      image_feature = JSON.parse(image.feature.convnet_feature)['features']
      image_feature = image_feature.map(&:to_i)

      distance = self.class.get_distance(my_feature, image_feature)
      similar.push({ image: image, distance: distance })
    end

    # Remove duplicates
    similar.uniq! { |value| value[:image] }

    # sort by evaluation value
    similar = similar.sort_by do |value|
      value[:distance]
    end

    similar
  end

  def self.get_distance(v1, v2)
    sum = 0
    (0..v1.count-1).each do |index|
      sum += (v1[index]-v2[index])*(v1[index]-v2[index])
    end
    Math.sqrt(sum)
  end

end
