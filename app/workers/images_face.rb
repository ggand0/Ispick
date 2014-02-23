class ImageFace
  # Woeker起動時に指定するQUEUE名
  @queue = :image_face

  def self.perform(target_id)
    image = Image.find(target_id)

    # 顔の特徴量を抽出する
    service = TargetImagesService.new
    face_feature = service.prefer(image)
    json_string = face_feature[:result].to_json

    feature = Face.new(face: json_string)
    image.feature = feature
    feature.save!
    #image.update_attributes({ face_feature: json_string })

    puts 'IMAGE : FACE EXTRACTION DONE!'
  end
end