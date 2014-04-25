class DetectIllust
  # Woeker起動時に指定するQUEUE名
  @queue = :detect_illust

  # イラスト判定ツールを実行し結果を得る
  def self.get_result(tool_path, image)
    %x(#{tool_path} #{image.data.path})
  end

  # イラストかどうか判定する
  def self.perform(image_type, image_id)
    begin
      # ツール実行
      image = Object::const_get(image_type).find(image_id)
      tool_path = CONFIG['illust_detection_path']

      # 結果をtrue/falseにparse
      illust = self.get_result(tool_path, image).to_i
      is_illust = (illust == 1 ? true : false)

      # 対象attributeをupdate
      image.update_attributes({is_illust: is_illust})
    rescue => e
      puts e
      Rails.logger.error('Illust detection failed!')
    end

    puts "Tool result: #{illust} with #{image_type}/#{image_id}"
  end
end