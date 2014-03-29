module DeliveredImagesHelper
  def show_targetable(delivered_image)
    id = delivered_image.targetable_id
    case delivered_image.targetable_type
      when 'TargetImage'
        return image_tag TargetImage.find(id).data.url(:thumb)
      when 'TargetWord'
        return TargetWord.find(id).word
    end
  end
end
