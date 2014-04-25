#-*- coding: utf-8 -*-
class DownloadImage
  # Woeker起動時に指定するQUEUE名
  @queue = :download_image

  # 画像をDLする
  def self.perform(image_type, image_id, src_url)
    image = Object::const_get(image_type).find(image_id)

    begin
      # 画像ダウンロード
      image.image_from_url src_url

      # DeliveredImageの場合はそのままイラスト判定へ
      # Imageオブジェクトの場合、全く同一のファイルを持つレコードが既にDBに存在すれば削除する
      if image.kind_of? Image and Image.where(md5_checksum: image.md5_checksum).count > 0
        Image.destroy(image_id)
        puts "Destroyed duplicates : #{image_type}/#{image_id}"
      else
        # それ以外はmd5_checksumを保存した後イラスト判定処理を行う
        image.save!
        Resque.enqueue(DetectIllust, image_type, image.id)
      end
    rescue => e
      puts e
      Rails.logger.error('Image download failed!')
      return
    end

    puts "Downloaded : #{image_type}/#{image_id}"
  end
end