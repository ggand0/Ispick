class Face
  # Woeker起動時に指定するQUEUE名
  @queue = :resque_face

  def self.perform(target_id)
    target_image = TargetImage.find(target_id)

    # 顔の特徴量を抽出する
    service = TargetImagesService.new
    face_feature = service.prefer(target_image)
    json_string = face_feature[:result].to_json

    Feature.transaction do
      feature.save!
      Image.transaction do
        target_image.feature = feature
      end
    end

    puts 'TARGET : FACE EXTRACTION DONE!'
  end
end