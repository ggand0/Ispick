#-*- coding: utf-8 -*-
class DownloadImage
  extend Resque::Plugins::Logger

  @queue = :download_image          # QUEUE name which is used when workers launch
  @log_name = 'download_image.log'  # File name which is written by Logger. Set worker name by default

  # Download images from the web, and set paperclip attachments to Image records
  # @param image_id [Integer] ID of Image record
  # @param src_url [String] Source url
  # @param user_id [Integer]
  # @param target_type [String]
  # @param target_id [Integer]
  def self.perform(image_id, image_type, src_url, user_id=nil, target_type=nil, target_id=nil)
    image = Object::const_get(image_type).find(image_id)

    begin
      # Download image from source url
      image.image_from_url(src_url)
      logger.info "user_id=#{user_id} image_id=#{image_id} src=#{src_url} #{target_id}"

      # Delete if a record in DB has the exact same file(based on checksum) exists
      # It's duplicate if the value is more than 1(because the file of given image is not saved yet)
      duplicates = Image.where(md5_checksum: image.md5_checksum)
      logger.debug "count: #{duplicates.count}"
      if duplicates.count > 0
        logger.debug "dup info: #{duplicates.first.id}"
        Image.destroy(image_id)
        logger.info "Destroyed duplicates : dup=#{duplicates.first.inspect}"
      else
        image.save!
        logger.info "Downloaded : Image.id=#{image_id}"

        # Image analysis
        #Resque.enqueue(DetectIllust, image.id)
        #Resque.enqueue(ImageFace, image.id)  # Stopped since 14/07/05
        #Resque.enqueue(ImageFeature, 'Image', image.id)  # Still testing 15/01/22
      end
    rescue => e
      logger.error e
    end
  end

end