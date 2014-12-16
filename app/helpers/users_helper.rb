module UsersHelper

  # ========================================================
  #  Bootstrap button helpers
  #  gem: https://github.com/Tretti/rails-bootstrap-helpers
  # ========================================================
  # Renders a image with the link.
  # @params image [Image] An object of Image.
  # @params image [Image] An object of Image which is included in the image.
  # @return []
  def render_image(image, size='btn-sm')
    link_to image_tag(image.data.url(:thumb)), { controller: 'images', action: 'show', id: image.id.to_s, remote: true, 'data-toggle' => "modal", 'data-target' => '#modal-image' },
      class: 'image'
  end

  def render_favored_image(image, size='btn-sm')
    link_to image_tag(image.data.url(:thumb)), { controller: 'favored_images', action: 'show', id: image.id.to_s, remote: true, 'data-toggle' => "modal", 'data-target' => '#modal-image' }
  end

  # Renders a bootstrap button with the link.
  # @params image [Image] An object of Image.
  def render_clip_button(image, size='btn-sm')
    bs_button_to paperclip_glyphicon, { controller: 'image_boards', action: 'boards', remote: true, image: image.id, id: "popover-board#{image.id}",
      class: "popover-board btn-info #{size}" }, 'data-toggle' => "popover", 'data-placement'=>'bottom', 'data-container'=> 'body', id: "popover-board#{image.id}"
  end

  # Renders a bootstrap button with the link.
  # @params image [Image] An object of Image.
  def render_unclip_button(image, size='btn-sm')
    bs_button_to 'Unclip', { controller: 'favored_images', action: 'destroy', id: image.id, board: @image_board.id }, method: :delete,
      class: "popover-board btn-info #{size}"
  end

  def render_like_button(image, size='btn-sm')
    bs_button_to thumbs_up_glyphicon, hide_image_path(image), method: :put, class: "btn-default #{size}"
  end

  # Renders a bootstrap button with the link.
  # @params image [Image] An object of Image.
  def render_hide_button(image, size='btn-sm')
    bs_button_to 'Hide', hide_image_path(image), method: :put, class: "btn-default #{size}"
  end

  # Renders a bootstrap button with the link.
  # @params image [Image] An object of Image.
  def render_show_button(image, size='btn-sm')
    bs_button_to resize_full_glyphicon, { controller: 'images', action: 'show', id: image.id.to_s, remote: true, 'data-toggle' => "modal", 'data-target' => '#modal-image' },
     class: "btn-default #{size}"
  end

  # Renders a bootstrap button with the link.
  # @params image [Image] An object of Image.
  def render_show_favored_button(image, size='btn-sm')
    bs_button_to resize_full_glyphicon, { controller: 'favored_images', action: 'show', id: image.id.to_s, remote: true, 'data-toggle' => "modal", 'data-target' => '#modal-image' },
     class: "btn-default #{size}"
  end


  # ==========================================
  #  Glyphicon helpers
  #  see: http://getbootstrap.com/components/
  # ==========================================
  def paperclip_glyphicon
    '<span class="glyphicon glyphicon-paperclip" style="vertical-align:middle"></span>'.html_safe
  end
  def resize_full_glyphicon
    '<span class="glyphicon glyphicon-resize-full" style="vertical-align:middle"></span>'.html_safe
  end
  def thumbs_up_glyphicon
    '<span class="glyphicon glyphicon-thumbs-up" style="vertical-align:middle"></span>'.html_safe
  end
  def thumbs_down_glyphicon
    '<span class="glyphicon glyphicon-thumbs-down" style="vertical-align:middle"></span>'.html_safe
  end
  def share_glyphicon
    '<span class="glyphicon glyphicon-share" style="vertical-align:middle"></span>'.html_safe
  end
  def tags_glyphicon
    '<span class="glyphicon glyphicon-tags" style="vertical-align:middle"></span>'.html_safe
  end
  def th_glyphicon
    '<span class="glyphicon glyphicon-th" style="vertical-align:middle"></span>'.html_safe
  end
  def wrench_glyphicon
    '<span class="glyphicon glyphicon-wrench" style="vertical-align:middle"></span>'.html_safe
  end
  def pencil_glyphicon
    '<span class="glyphicon glyphicon-pencil" style="vertical-align:middle"></span>'.html_safe
  end
  def comment_glyphicon
    '<span class="glyphicon glyphicon-comment" style="vertical-align:middle"></span>'.html_safe
  end
  def user_glyphicon
    '<span class="glyphicon glyphicon-user" style="vertical-align:middle"></span>'.html_safe
  end
  def link_glyphicon
    '<span class="glyphicon glyphicon-link" style="vertical-align:middle"></span>'.html_safe
  end
  def plus_glyphicon
    '<span class="glyphicon glyphicon-plus" style="vertical-align:middle"></span>'.html_safe
  end
  def remove_glyphicon
    '<span class="glyphicon glyphicon-remove" style="vertical-align:middle"></span>'.html_safe
  end
  def list_glyphicon
    '<span class="glyphicon glyphicon-list" style="vertical-align:middle"></span>'.html_safe
  end
  def file_glyphicon
    '<span class="glyphicon glyphicon-file" style="vertical-align:middle"></span>'.html_safe
  end
  def search_glyphicon
    '<span class="glyphicon glyphicon-search" style="vertical-align:middle"></span>'.html_safe
  end



  # =================
  #  DEBUG BUTTONS
  #  will be deleted
  # =================
  def render_show_debug_button(image, size='btn-sm')
    bs_button_to wrench_glyphicon, { controller: 'debug', action: 'show_debug', id: image.id.to_s, remote: true, 'data-toggle' => "modal", 'data-target' => '#modal-image' },
      class: "btn-default #{size}"
  end
  def render_clip_debug_button(image)
    bs_button_to paperclip_glyphicon, { controller: 'debug', action: 'boards_another', remote: true, image: image.id, id: "popover-board#{image.id}",
    class: 'popover-board btn-info btn-xs' }, 'data-toggle' => "popover", 'data-placement'=>'bottom', 'data-container'=> 'body'#, id: "popover-board#{image.id}"
  end
  # Another show button with smaller option
  def render_show_another_button(image)
    bs_button_to resize_full_glyphicon, { controller: 'images', action: 'show', id: image.id.to_s, remote: true, 'data-toggle' => "modal", 'data-target' => '#modal-image' },
    class: 'btn-default btn-xs'
  end


  # ======================
  #  HTML related helpers
  #  (just for debugging)
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
  def get_debug_html(count)
    "<strong>Found #{count} images.</strong>".html_safe
  end
end
