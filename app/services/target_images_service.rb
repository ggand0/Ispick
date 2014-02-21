require "pp"
require "rubygems"
require "AnimeFace"
require "RMagick"

class TargetImagesService
  def prefer(target_image)
    url = target_image.data.path.split('?')[0]
    image = Magick::ImageList.new(url)
    result0 = AnimeFace::detect(image)
    #result1 = AnimeFace::detect(image, { :step => 2.0, :min_window_size => 32, :scale_factor => 1.1 })

    #preferred = []
    #preferred
    result0
  end
end