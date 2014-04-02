class DetectIllust
  # Woeker起動時に指定するQUEUE名
  @queue = :detect_illust

  def self.perform(image_id)
    image = Image.find(image_id)
    tool_path = "#{Rails.root}/lib/opencv.exe"

    # イラストかどうか判定する
    puts image.data.path
    illust = %x(#{tool_path} #{image.data.path} 2>&1)
    puts illust
    is_illust = (illust == 1 ? true : false)
    image.update_attributes({is_illust: is_illust})

    puts 'ILLUST DETECTION DONE!'
  end
end