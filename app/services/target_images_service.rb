require 'pp'
require 'rubygems'
require 'AnimeFace'
require 'RMagick'

class TargetImagesService
  def get_face_feature(image_url)
    url = image_url.split('?')[0]
    image = Magick::ImageList.new(url)
    result0 = AnimeFace::detect(image)
    result0
  end

  def prefer(target_image)
    start_time = Time.now
    url = target_image.data.path.split('?')[0]
    image = Magick::ImageList.new(url)
    result = AnimeFace::detect(image)
    #result1 = AnimeFace::detect(image, { :step => 2.0, :min_window_size => 32, :scale_factor => 1.1 })
    end_time = Time.now
    time = (end_time - start_time).to_s

    json = { time: time, result: result }
    json
  end
end