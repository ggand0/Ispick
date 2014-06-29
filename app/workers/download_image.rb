#-*- coding: utf-8 -*-
class DownloadImage
  extend Resque::Plugins::Logger

  @queue = :download_image          # Woeker起動時に指定するQUEUE名
  @log_name = 'download_image.log'  # Loggerが書き込むファイル名。デフォルトではworker名

  # 画像をWebからダウンロードしてpaperclipのattachmentを設定する
  # @param image_type [String] 画像オブジェクトのクラス名
  # @param image_id [Integer] テーブル内のID
  # @param src_url [String] Source url
  def self.perform(image_type, image_id, src_url, target_type=nil, target_id=nil)
    image = Object::const_get(image_type).find(image_id)

    begin
      # 画像をsource urlからダウンロード
      image.image_from_url src_url

      # DeliveredImageの場合は、そのままイラスト判定へ
      # Imageオブジェクトの場合は、全く同一のファイルを持つレコードが既にDBに存在すれば削除する
      if image.kind_of? Image and Image.where(md5_checksum: image.md5_checksum).count > 0
        Image.destroy(image_id)
        logger.info "Destroyed duplicates : #{image_type}/#{image_id}"
      else
        # DBに保存
        image.save!
        logger.info "Downloaded : #{image_type}/#{image_id}"

        # 画像解析処理
        Resque.enqueue(DetectIllust, image_type, image.id)
        Resque.enqueue(ImageFace, image_type, image.id)

        # Targetableの情報が設定されている場合は、
        # （登録直後の配信だと判断し）ユーザへ配信する
        target =  Object::const_get(target_type).find(target_id)
        Deliver.deliver_image(target.user_id, target, image_id)
      end
    rescue => e
      logger.info e
      logger.error('Image download failed!')
    end
  end

end