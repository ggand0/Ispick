#-*- coding: utf-8 -*-
class CopyImage
  # Woeker起動時に指定するQUEUE名
  @queue = :copy_image

  # 画像をDLする
  def self.perform(image_id, data)
    image = Image.find(image_id)

    begin
      image.data = data
      image.save!
    rescue => e
      puts e
      Rails.logger.error('Image download failed!')
      return
    end

    puts 'COPY IMAGE DONE!'
  end
end