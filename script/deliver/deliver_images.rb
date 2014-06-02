
module Deliver::Images
  THRESHOLD = 70

  # 登録画像から配信する
  # @param [User] 配信するUserレコードのインスタンス
  # @param [TargetImage] 保存済みのTargetImageレコード
  def self.deliver_from_image(user, target_image)

    # 推薦イラストを取得
    puts 'Delivering from a target_image...'
    images = self.get_images true

    # 類似度が一定値以上であるimageがあれば残す
    # 類似度が遠いimageをnilに置き換えた後全て削除
    images = images.map do |image|
      self.close_image(image, target_image, THRESHOLD) ? image : nil
    end
    images.compact!
    puts "Got images: #{images.count.to_s}"

    #images = images.map{ |image| image[:image] }             # Hashのarrayではなく単純なImageのarrayにする
    images = Deliver.limit_images(user, images)               # 配信画像を制限する
    Deliver.deliver_images(user, images, target_image, true)  # User.delivered_imagesへ追加
    target_image.last_delivered_at = DateTime.now             # 最終配信日時を記録
  end

  # AnimeFaceの特徴量から近い画像を探す
  def self.get_animeface_images
    service = TargetImagesService.new
    result = service.get_preferred_images(target_image)
    images = result[:images]
    images
  end

  # 文字情報が存在するImageレコードを検索して返す
  # @param [Boolean] 定時配信で呼ばれたのかどうか
  # @return [ActiveRecord_Relation_Image]
  def self.get_images(is_periodic)
    if is_periodic
      # 定時配信の場合は、イラスト判定が終了している[is_illustがnilではない]もののみ配信
      images = Image.joins(:feature).
        where.not(features: { categ_imagenet: nil }).
        where.not(features: { categ_imagenet: '{}' }).
        includes(:feature)
    else
      # 即座に配信するときは、イラスト判定を後で行う事が確定しているのでnilのレコードも許容する：
      # が、既存のDL失敗画像で落ちる可能性が高いので要修正
      images = Image.all
    end
    images
  end

  # TargetImageに近いImageかどうか判定する
  # @param [Image] 判定したいImageオブジェクト
  # @param [TargetImage] 比較したいTargetImageオブジェクト
  # @param [Integer] 閾値
  # @return [Boolean] TargetImageに近いかどうか
  def self.close_image(image, target_image, th)
    start = Time.now

    hash1 = JSON.parse(image.feature.categ_imagenet)
    hash2 = JSON.parse(target_image.feature.categ_imagenet)

    # 0層の場合：keyから類似度を計算
    # -2層の場合：vectorのnormを計算して距離を比較する
    subtracted = hash1.values.zip(hash2.values).map { |x, y| y - x }
    norm = Vector.elements(subtracted, true).norm

    puts norm.abs
    puts "Elapsed: #{Time.now - start}"

    norm.abs < th
  end
end