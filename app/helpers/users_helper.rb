module UsersHelper
  def get_clip_string(delivered_image)
    if not delivered_image.favored
      'Clip'
    else
      'Unclip'
    end
  end

  def get_clip_string_styled(delivered_image)
    style = ''
    if not delivered_image.favored
      style = 'style="color: #000;"'
    else
      style = 'style="color: #02C293;"'
    end
    '<span '+style+'>' + get_clip_string(delivered_image) + '</span>'
  end
end
