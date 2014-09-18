module UsersHelper
  # ======================
  #  HTML related helpers
  # ======================
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
  # @params image [ActiveRecord::AssociationRelation] A relation object of Image class.
  # @return [String] html code with the count of input relation.
  def get_debug_html(images)
    "<strong>Found #{images.count} images.</strong>".html_safe
  end

  # ===================
  #  Rendering helpers
  # ===================
  # Renders a image with the link.
  # @params image [Image] An object of Image.
  # @params image [Image] An object of Image which is included in the image.
  # @return []
  def render_image(image)
    link_to image_tag(image.data.url(:thumb)), { controller: 'images', action: 'show', id: image.id.to_s, remote: true, 'data-toggle' => "modal", 'data-target' => '#modal-image' }
  end

  # Renders a bootstrap button with the link.
  # @params image [Image] An object of Image.
  def render_clip_button(image)
    bs_button_to 'Clip', { controller: 'image_boards', action: 'boards', remote: true, image: image.id, id: "popover-board#{image.id}", class: 'popover-board btn-info btn-sm' }, 'data-toggle' => "popover", 'data-placement'=>'bottom', 'data-container'=> 'body', id: "popover-board#{image.id}"
  end

  # Renders a bootstrap button with the link.
  # @params image [Image] An object of Image.
  def render_unclip_button(image)
    bs_button_to 'Unclip', { controller: 'favored_images', action: 'destroy', id: image.id, board: @image_board.id }, method: :delete, class: 'popover-board btn-info btn-sm'
  end

  # Renders a bootstrap button with the link.
  # @params image [Image] An object of Image.
  def render_hide_button(image)
    bs_button_to 'Hide', hide_image_path(image), method: :put, class: 'btn-default btn-sm'
  end

  # Renders a bootstrap button with the link.
  # @params image [Image] An object of Image.
  def render_show_button(image)
    bs_button_to 'Show', { controller: 'images', action: 'show', id: image.id.to_s, remote: true, 'data-toggle' => "modal", 'data-target' => '#modal-image' }, class: 'btn-default btn-sm'
  end

  def render_show_debug_button(image)
    bs_button_to 'Debug', { controller: 'images', action: 'show_debug', id: image.id.to_s, remote: true, 'data-toggle' => "modal", 'data-target' => '#modal-image' }, class: 'btn-default btn-sm'
  end


  # =======
  #  DEBUG
  # =======
  def render_clip_debug_button(image)
    bs_button_to 'Clip', { controller: 'image_boards', action: 'boards_another', remote: true, image: image.id, id: "popover-board#{image.id}",
    class: 'popover-board btn-info btn-xs' }, 'data-toggle' => "popover", 'data-placement'=>'bottom', 'data-container'=> 'body', id: "popover-board#{image.id}"
  end
  def render_show_another_button(image)
    bs_button_to 'Show', { controller: 'images', action: 'show', id: image.id.to_s, remote: true, 'data-toggle' => "modal", 'data-target' => '#modal-image' },
    class: 'btn-default btn-xs'
  end
end
