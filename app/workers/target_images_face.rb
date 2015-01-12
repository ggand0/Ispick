# ========================
#  Not in use on 12/01/15
# ========================
class TargetFace
  # Set QUEUE name
  @queue = :target_face

  # @param [TargetImage] A record of TargetImage model which has already saved.
  # @return [Hash] ImageNet categories included.
  def self.get_categories(target_image)
    #tool_path = "#{Rails.root}/lib/deep_belief"
    tool_path = "#{Rails.root}/lib/deep_belief_-2"
    network_path = "#{Rails.root}/lib/jetpac.ntwk"
    puts target_image.data.path
    result = %x(#{tool_path} #{target_image.data.path} #{network_path})

    hash = {}
    result.split("\n").each do |line|
      tmp = line.split(',')
      hash[tmp[1]] = tmp[0].to_f
    end

    # To make it faster, set 0 to keys that have no labels
    (0..4095).each do |key|
      hash[key.to_s] = 0 if not hash.has_key?(key.to_s)
    end
    hash.delete(nil)

    hash
  end

  def self.perform(target_id)
    target_image = TargetImage.find(target_id)

=begin
    # Extract face features
    service = TargetImagesService.new
    face_feature = service.prefer(target_image)
    json_string = face_feature[:result].to_json

    feature = Feature.new(face: json_string)
=end
    puts json_string = self.get_categories(target_image).to_json
    feature = Feature.new(convnet_feature: json_string)
    Feature.transaction do
      feature.save!
      TargetImage.transaction do
        target_image.feature = feature
      end
    end

    puts 'TARGET : FACE EXTRACTION DONE!'
  end
end