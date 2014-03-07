require 'pp'
require 'rubygems'
require 'AnimeFace'
require 'RMagick'

class TargetImagesService
  # URL先の画像の顔特徴量をデフォルト設定で抽出する
  def get_face_feature(image_url)
    image = Magick::ImageList.new(image_url)
    AnimeFace::detect(image)
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


  def get_preferred_images(target_image)
    preferred = []
    target_colors = {}

    face_feature = JSON.parse(target_image.feature.face)
    target_colors = Utility::get_colors(face_feature, true)

    Image.all.each do |image|
      # 抽出されていないか、抽出出来ていないImageは飛ばす
      if (not image.feature.nil? and image.feature.face == '[]' or
        image.feature.nil?)
        next
      end

      image_face = JSON.parse(image.feature.face)
      image_colors = Utility::get_colors(image_face, true)

      distance = Utility::hsv_distance(target_colors[:hair], image_colors[:hair])
      if distance < 30 and
        Utility::hsv_distance(target_colors[:left_eye], image_colors[:left_eye]) < 100 and
        Utility::hsv_distance(target_colors[:right_eye], image_colors[:right_eye]) < 100

        hsv = Utility::round_array(image_colors[:hair])
        preferred.push({image: image, hsv: distance})
      end
    end

    {images: preferred, target_colors: target_colors}
  end

end