module UsersHelper
  def get_clip_string(delivered_image)
    if not delivered_image.favored
      'Clip'
    else
      'Unclip'
    end
  end
end
