#-*- coding: utf-8 -*-
class CopyImage
  # Woeker起動時に指定するQUEUE名
  @queue = :copy_image

  # 画像をcopyする
  def self.perform(delivered_image_id, image_id)
    image = Image.find(image_id)
    delivered_image = DeliveredImage.find(delivered_image_id)
    delivered_image.data.destroy

    begin
      #puts delivered_image.data
      puts image.data
      delivered_image.data = image.data
      delivered_image.save!
      puts DeliveredImage.find(delivered_image_id).data
    rescue => e
      puts e
      Rails.logger.error('Image copy failed! Needs to be re-delivered.')
      return
    end

    puts 'COPY IMAGE DONE!'
  end
end