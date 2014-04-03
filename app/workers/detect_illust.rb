class DetectIllust
  # Woeker起動時に指定するQUEUE名
  @queue = :detect_illust

  # イラスト判定ツールを実行し結果を得る
  def self.get_result(tool_path, image)
    %x(#{tool_path} #{image.data.path})#2>&1
  end

  # イラストかどうか判定する
  def self.perform(image_id)
    image = Image.find(image_id)
    tool_path = CONFIG['illust_detection_path']
    illust = self.get_result(tool_path, image).to_i

    begin
      is_illust = (illust == 1 ? true : false)
    rescue => e
      puts e
      Rails.logger.error('Illust detection failed!')
      is_illust = false
    end
    image.update_attributes({is_illust: is_illust})

    puts 'ILLUST DETECTION DONE!'
  end
end