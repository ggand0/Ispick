#-*- coding: utf-8 -*-
# ========================
#  Not in use on 12/01/15
# ========================
class DownloadImageLarge
  # Set QUEUE name
  @queue = :download_image_large

  # Download image from the web
  def self.perform(image_type, image_id, src_url)
    image = Object::const_get(image_type).find(image_id)

    begin
      # Download image
      image.image_from_url src_url

      if image.kind_of? Image and Image.where(md5_checksum: image.md5_checksum).count > 0
        Image.destroy(image_id)
        puts "Destroyed duplicates : #{image_type}/#{image_id} (large)"
      else
        image.save!
        Resque.enqueue(DetectIllust, image_type, image.id)
      end
    rescue => e
      puts e
      Rails.logger.error('Image download failed! (large)')
      return
    end

    puts "Downloaded : #{image_type}/#{image_id} (large)"
  end
end