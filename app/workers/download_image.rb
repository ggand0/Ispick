#-*- coding: utf-8 -*-
class DownloadImage
  extend Resque::Plugins::Logger

  @queue = :download_image          # Woeker起動時に指定するQUEUE名
  @log_name = 'download_image.log'  # Loggerが書き込むファイル名。デフォルトではworker名

  # 画像をWebからダウンロードしてpaperclipのattachmentを設定する
  # targetableが登録直後の抽出処理で、そのまま配信する場合はオプション引数を全て設定する必要がある
  # @param image_id [Integer] テーブル内のID
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
      # 全く同一のファイルを持つレコードが既にDBに存在すれば削除する
      # 自分自身は、変更を加えた後まだ保存していないので含まれない、1以上なら重複
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
        #Resque.enqueue(ImageFace, image.id)  # 14/07/05停止中
        Resque.enqueue(ImageFeature, 'Image', image.id)

        # ===================================
        # Targetableの情報が設定されている場合は、
        # 登録直後の配信だと判断しユーザへ配信する
        # ===================================
        unless user_id.nil?
          target = Object::const_get(target_type).find(target_id)
          Deliver.deliver_image(user_id, target, image_id)
        end
      end
    rescue => e
      logger.error e
    end
  end

end