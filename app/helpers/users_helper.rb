module UsersHelper
  def get_clip_string(delivered_image)
    if delivered_image.favored_images.count > 0
      'Clipped'
    else
      'Clip'
    end
  end

  def get_clip_string_styled(delivered_image)
    style = ''
    if delivered_image.favored_images.count > 0
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
  def get_enabled_html(enabled)
    '<strong>' + (enabled ? 'on' : 'off') + '</strong>'
  end
  def get_illust_html(image)
    return 'Illust: nil' if image.nil?
    "Illust: <span><strong>#{image.is_illust.to_s}</strong></span>".html_safe
  end
  def get_quality_html(image)
    return 'Quality: nil' if image.nil?
    "Quality: <span><strong>#{image.quality.to_s}</strong></span>".html_safe
  end

end
