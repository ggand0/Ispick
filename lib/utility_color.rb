module Utility

  def self.rgb_to_hsv(r, g, b, cone_model)
    h = 0
    s = 0
    v = 0
    max = [[r, g].max, b].max
    min = [[r, g].min, b].min

    # hue
    if max == min
      h = 0
    elsif max == r
      h = (60 * (g - b) * 1.0 / (max - min)*1.0) + 0
    elsif max == g
      h = (60 * (b - r) * 1.0 / (max - min)*1.0) + 120
    else
      h = (60 * (r - g) * 1.0 / (max - min)*1.0) + 240
    end

    while h < 0 do
      h += 360
    end

    # saturation
    if cone_model
      s = max - min
    else
      #s = 0 if max==0 else (max-min)*1.0/max*255*1.0
      if max == 0
        s = 0
      else
        s = (max-min)*1.0 / max*255*1.0
      end
    end

    # value
    v = max

    [h, s, v]
  end

  def self.round_array(array)
    result = []
    array.each do |i|
      result.push("%.2f" % i)
    end
    result
  end
end