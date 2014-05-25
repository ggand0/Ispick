class ImageFace
  # Woeker起動時に指定するQUEUE名
  @queue = :image_face

  # @param [Image/TargetImage] A record of TargetImage model which has already saved.
  # @return [Hash] ImageNet categories included.
  def self.get_categories(image)
    tool_path = "#{Rails.root}/lib/deep_belief"
    network_path = "#{Rails.root}/lib/jetpac.ntwk"
    result = %x(#{tool_path} #{image.data.path} #{network_path})

    hash = {}
    result.split("\n").each do |line|
      tmp = line.split(',')
      hash[tmp[1]] = tmp[0].to_f
    end
    hash
  end

  def self.perform(image_type, image_id)
    image = Object::const_get(image_type).find(image_id)

    # ImageNetのカテゴリ分類処理
    puts json_string = self.get_categories(image).to_json
    feature = Feature.new(categ_imagenet: json_string)

    Feature.transaction do
      feature.save!
      Image.transaction do
        image.feature = feature
      end
    end

    puts 'IMAGE : FACE EXTRACTION DONE!'
  end
end