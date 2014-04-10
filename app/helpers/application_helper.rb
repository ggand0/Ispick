module ApplicationHelper
  # [KB]
  def bytes_to_kilobytes(byte)
    return 0 if not byte      # nilの場合0を返す
    (byte / 1024.0).round(3)  # KBに換算する
  end
  # [MB]
  def bytes_to_megabytes(byte)
    return 0 if not byte
    (byte / (1024.0*1024.0)).round(3)
  end
  # [KB]
  def bytes_to_kilobytes_mac(byte)
    return 0 if not byte
    (byte / 1000.0).round(3)
  end
  # [MB]
  def bytes_to_megabytes_mac(byte)
    return 0 if not byte
    (byte / (1000.0*1000.0)).round(3)
  end

  # [byte]
  def get_total_size(images)
    total_size = 0
    images.each { |n| total_size += n.data.size }
    total_size
  end

  # DateTime
  def utc_to_jst(datetime)
    datetime.in_time_zone('Asia/Tokyo')
  end

  # string
  def get_time_string(datetime)
    datetime.strftime("%Y年%m月%d日%H時%M分")
  end
end
