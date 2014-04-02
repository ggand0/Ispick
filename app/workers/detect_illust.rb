class DetectIllust
  # Woeker起動時に指定するQUEUE名
  @queue = :detect_illust

  def self.perform(image_id)
    image = Image.find(image_id)
    tool_path = "#{Rails.root}/lib/opencv"

    # イラストかどうか判定する
    illust = %x(#{tool_path} #{image.data.path} 2>&1)
    image.update_attribute(is_illust: (illust == 1 ? true : false))

    puts 'ILLUST DETECTION DONE!'
  end
end