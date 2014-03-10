module Utility
  def self.is_preferred(dist_hash, th_array)
    dist_hash[:hair] <= th_array[0] and
      dist_hash[:skin] <= th_array[1] and
      dist_hash[:left_eye] <= th_array[2] and
      dist_hash[:right_eye] <= th_array[3]
  end

  def self.evaluate_face_colors(dist_hash, th_array)
    dist_hash[:hair] * th_array[0] + dist_hash[:skin] * th_array[1] +
      dist_hash[:left_eye] * th_array[2] + dist_hash[:right_eye] * th_array[3]
  end

  def self.get_colors(hash, is_hsv)
    color_hash = {}

    # hair
    r = hash['hair_color']['red'].to_i
    g = hash['hair_color']['green'].to_i
    b = hash['hair_color']['blue'].to_i
    color_hash[:hair] = [r, g, b]

    # skin
    r = hash['skin_color']['red'].to_i
    g = hash['skin_color']['green'].to_i
    b = hash['skin_color']['blue'].to_i
    color_hash[:skin] = [r, g, b]

    # eyes
    r = hash['eyes']['left']['colors']['red'].to_i
    g = hash['eyes']['left']['colors']['green'].to_i
    b = hash['eyes']['left']['colors']['blue'].to_i
    color_hash[:left_eye] = [r, g, b]

    r = hash['eyes']['right']['colors']['red'].to_i
    g = hash['eyes']['right']['colors']['green'].to_i
    b = hash['eyes']['right']['colors']['blue'].to_i
    color_hash[:right_eye] = [r, g, b]

    # Convert rgb to hsv
    if is_hsv
      color_hash[:hair] = Utility::rgb_to_hsv(color_hash[:hair], false)
      color_hash[:skin] = Utility::rgb_to_hsv(color_hash[:skin], false)
      color_hash[:left_eye] = Utility::rgb_to_hsv(color_hash[:left_eye], false)
      color_hash[:right_eye] = Utility::rgb_to_hsv(color_hash[:right_eye], false)
    end

    color_hash
  end

  # Get rgb color of eyes from feature hash
  def self.get_eye_color(hash, which_eye)
    r = hash['eyes'][which_eye]['colors']['red'].to_i
    g = hash['eyes'][which_eye]['colors']['green'].to_i
    b = hash['eyes'][which_eye]['colors']['blue'].to_i
    [r, g, b]
  end

  # Get rgb color of hair / skin from feature hash
  def self.get_face_color(hash, which_part)
    r = hash[which_part]['red'].to_i
    g = hash[which_part]['green'].to_i
    b = hash[which_part]['blue'].to_i
    [r, g, b]
  end

  # Calculate hsv distance to all face feature
  def self.get_hsv_distance(color_hash0, color_hash1)
    dist_hash = {}
    dist_hash[:hair] = Utility.hsv_distance(color_hash0[:hair], color_hash1[:hair])
    dist_hash[:skin] = Utility.hsv_distance(color_hash0[:skin], color_hash1[:skin])
    dist_hash[:left_eye] = Utility.hsv_distance(color_hash0[:left_eye], color_hash1[:left_eye])
    dist_hash[:right_eye] = Utility.hsv_distance(color_hash0[:right_eye], color_hash1[:right_eye])
    dist_hash
  end

  # Calculate a distance of two hsv value
  def self.hsv_distance(hsv0, hsv1)
    dif = [hsv1[0]-hsv0[0], hsv1[1]-hsv0[1], hsv1[2]-hsv0[2]]
    Math.sqrt(dif[0]*dif[0] + dif[1]*dif[1] + dif[2]*dif[2])
  end

  # Round values in an array
  def self.round_array(array, n=2)
    array.map{ |i| i.round(n) }
  end

  # Convert RGB value to HSV value
  def self.rgb_to_hsv(rgb, cone_model)
    r = rgb[0]
    g = rgb[1]
    b = rgb[2]
    h = 0
    s = 0
    v = 0
    max = [r, g, b].max
    min = [r, g, b].min
    #puts max.to_s + ' ' + min.to_s

    # hue
    if max == min
      h = 0
    elsif max == r
      h = (60*(g - b) / (max - min)*1.0) + 0
    elsif max == g
      h = (60*(b - r) / (max - min)*1.0) + 120
    else
      h = (60*(r - g) / (max - min)*1.0) + 240
    end

    while h < 0 do
      h += 360
    end

    # saturation
    if cone_model
      s = max - min
    else
      if max == 0
        s = 0
      else
        s = ((max - min) / (max*1.0)) * 255
      end
    end

    # value
    v = max

    # Conver SV to % style
    [h, s/255.0*100, v/255.0*100]
  end

end