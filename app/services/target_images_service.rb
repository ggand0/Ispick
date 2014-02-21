require "pp"
require "rubygems"
require "AnimeFace"
require "RMagick"

class TargetImagesService
  def prefer(target_image)
    start_time = Time.now
    url = target_image.data.path.split('?')[0]
    image = Magick::ImageList.new(url)
    result0 = AnimeFace::detect(image)
    end_time = Time.now
    time = (end_time - start_time).to_s

    result = []
    result.push(time)
    result.push(result0)
    result
    #result1 = AnimeFace::detect(image, { :step => 2.0, :min_window_size => 32, :scale_factor => 1.1 })
  end
end