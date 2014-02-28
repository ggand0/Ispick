module Utility
  # Round values in an array
  def self.round_array(array, n=2)
    array.map{ |i| i.round(n) }
  end

  # Convert RGB value to HSV value
  def self.rgb_to_hsv(r, g, b, cone_model)
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