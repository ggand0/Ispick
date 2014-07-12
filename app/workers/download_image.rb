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
  def self.perform(image_id, src_url, user_id=nil, target_type=nil, target_id=nil)
    image = Image.find(image_id)

    begin
      # 画像をsource urlからダウンロード
      image.image_from_url(src_url)
      logger.info "Target hash: #{image.md5_checksum}"
      logger.info "Target relation: #{Image.where(md5_checksum: image.md5_checksum).count}"

      # 全く同一のファイルを持つレコードが既にDBに存在すれば削除する
      # 対象とするレコードの分も含めて2以上なら重複と判断し削除
      # 自分自身はまだ保存していないので、1以上なら重複
      if Image.where(md5_checksum: image.md5_checksum).count > 0#1
        Image.destroy(image_id)
        logger.info "Destroyed duplicates : Image.id=#{image_id}"
      else
        # DBに保存
        image.save!
        logger.info "Downloaded : Image.id=#{image_id}"

        # 画像解析処理
        Resque.enqueue(DetectIllust, image.id)
        #Resque.enqueue(ImageFace, image.id)  # 14/07/05停止中

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
      logger.error('Image download failed!')
    end
  end

end