#-*- coding: utf-8 -*-
class DownloadImage
  # Woeker起動時に指定するQUEUE名
  @queue = :download_image

  # 画像をDLする
  def self.perform(image_id, src_url)
    image = Image.find(image_id)

    begin
      image.image_from_url src_url
      image.save!
    rescue => e
      puts e
      Rails.logger.error('Image download failed!')
      return
    end

    puts 'DOWNLOAD IMAGE DONE!'
  end
end