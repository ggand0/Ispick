module DeliveredImagesHelper
  def show_targetable(delivered_image)
    id = delivered_image.targetable_id
    case delivered_image.targetable_type
      when 'TargetImage'
        if TargetImage.where(id:id).empty?
          return "[TargetImage id=#{id.to_s}]"
        else
          return image_tag TargetImage.find(id).data.url(:thumb)
        end
      when 'TargetWord'
        if TargetWord.where(id:id).empty?
          return "[TargetWord id=#{id.to_s}]"
        else
          return TargetWord.find(id).word
        end
    end
    ''
  end
end
