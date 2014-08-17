module UsersHelper
  # Calculates the file size of a favored_image relation.
  # @params favored_images [ActiveRecord::AssociationRelation]
  # @return [Integer] Total file size[bytes] of the relation
  def get_total_size_favored(favored_images)
    total_size = 0
    favored_images.each do |n|
      # まだコピーされていない(生存中のDeliveredImageを参照している)
      if n.delivered_image_id
        image = DeliveredImage.find(n.delivered_image_id)
        total_size += image.data.size
      # 既にコピーされている(ソース元のDeliveredImageは削除されている)
      else
        total_size += n.data.size
      end
    end
    total_size
  end

  # Returns html code for debugging.
  # @params image [Image] An Image object.
  # @return [String] html code with is_illust value.
  def get_illust_html(image)
    return 'Illust: nil' if image.nil?
    "Illust: <span><strong>#{image.is_illust.to_s}</strong></span>".html_safe
  end

  # Returns html code for debugging.
  # @params image [Image] An Image object.
  # @return [String] html code with quality value.
  def get_quality_html(image)
    return 'Quality: nil' if image.nil?
    "Quality: <span><strong>#{image.quality.to_s}</strong></span>".html_safe
  end

  # Returns html code for debugging.
  # @params delivered_image [ActiveRecord::AssociationRelation] A relation object of DeliveredImage class.
  # @return [String] html code with the count of input relation.
  def get_debug_html(delivered_images)
    #"<strong>Found #{@delivered_images_all.count} delivered_images.</strong".html_safe
    "<strong>Found #{delivered_images.count} delivered_images.</strong>".html_safe
  end

  # ===================
  #  Rendering helpers
  # ===================
  # Renders a delivered_image with the link.
  # @params delivered_image [DeliveredImage] An object of DeliveredImage.
  # @params image [Image] An object of Image which is included in the delivered_image.
  # @return []
  #def render_delivered_image(delivered_image, image)
  #  link_to image_tag(image.data.url(:thumb)), { controller: 'delivered_images', action: 'show', id: delivered_image.id.to_s, remote: true, 'data-toggle' => "modal", 'data-target' => '#modal-image' }
  #end
  def render_delivered_image(image)
    link_to image_tag(image.data.url(:thumb)), { controller: 'images', action: 'show', id: image.id.to_s, remote: true, 'data-toggle' => "modal", 'data-target' => '#modal-image' }
  end

  # Renders a bootstrap button with the link.
  # @params delivered_image [DeliveredImage] An object of DeliveredImage.
  def render_clip_button(delivered_image)
    bs_button_to 'Clip', { controller: 'image_boards', action: 'boards', remote: true, image: delivered_image.id, id: "popover-board#{delivered_image.id}", class: 'popover-board btn-info btn-sm' }, 'data-toggle' => "popover", 'data-placement'=>'bottom', 'data-container'=> 'body', id: "popover-board#{delivered_image.id}"
  end

  # Renders a bootstrap button with the link.
  # @params delivered_image [DeliveredImage] An object of DeliveredImage.
  def render_hide_button(delivered_image)
    bs_button_to 'Hide', avoid_delivered_image_path(delivered_image), method: :put, class: 'btn-default btn-sm'
  end

  # Renders a bootstrap button with the link.
  # @params delivered_image [DeliveredImage] An object of DeliveredImage.
  def render_show_button(delivered_image)
    bs_button_to 'Show', { controller: 'delivered_images', action: 'show', id: delivered_image.id.to_s, remote: true, 'data-toggle' => "modal", 'data-target' => '#modal-image' }, class: 'btn-default btn-sm'
  end

end
