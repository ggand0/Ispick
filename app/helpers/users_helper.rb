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

  def get_illust_html(image)
    return 'Illust: nil' if image.nil?
    "Illust: <span><strong>#{image.is_illust.to_s}</strong></span>".html_safe
  end

  def get_quality_html(image)
    return 'Quality: nil' if image.nil?
    "Quality: <span><strong>#{image.quality.to_s}</strong></span>".html_safe
  end

  def get_debug_html(delivered_images)
    "<strong>Found #{@delivered_images_all.count} delivered_images.</strong".html_safe
  end

  # ===================
  #  Rendering helpers
  # ===================
  def render_delivered_image(delivered_image, image)
    link_to image_tag(image.data.url(:thumb)), { controller: 'delivered_images', action: 'show', id: delivered_image.id.to_s, remote: true, 'data-toggle' => "modal", 'data-target' => '#modal-image' }
  end

  def render_clip_button(delivered_image)
    bs_button_to 'Clip', { controller: 'image_boards', action: 'boards', remote: true, image: delivered_image.id, id: "popover-board#{delivered_image.id}", class: 'popover-board btn-info btn-sm' }, 'data-toggle' => "popover", 'data-placement'=>'bottom', 'data-container'=> 'body', id: "popover-board#{delivered_image.id}"
  end

  def render_hide_button(delivered_image)
    bs_button_to 'Hide', avoid_delivered_image_path(delivered_image), method: :put, class: 'btn-default btn-sm'
  end

  def render_show_button(delivered_image)
    bs_button_to 'Show', { controller: 'delivered_images', action: 'show', id: delivered_image.id.to_s, remote: true, 'data-toggle' => "modal", 'data-target' => '#modal-image' }, class: 'btn-default btn-sm'
  end

end
