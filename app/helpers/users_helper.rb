module UsersHelper
  def get_clip_string(delivered_image)
    if delivered_image.favored_image_id
      'Clipped'
    else
      'Clip'
    end
  end

  def get_clip_string_styled(delivered_image)
    style = ''
    if delivered_image.favored_image_id
      style = 'style="color: #02C293;"'
    else
      style = 'style="color: #000;"'
    end
    '<span '+style+'>' + get_clip_string(delivered_image) + '</span>'
  end

  def get_total_size_favored(favored_images)
    total_size = 0
    favored_images.each do |n|
      if n.delivered_image_id # まだコピーされていない(生存中のDeliveredImageを参照している)
        image = DeliveredImage.find(n.delivered_image_id)
        total_size += image.data.size
      else                    # 既にコピーされている(ソース元のDeliveredImageは削除されている)
        total_size += n.data.size
      end
    end
    total_size
  end
end
