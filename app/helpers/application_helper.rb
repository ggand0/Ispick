module ApplicationHelper
  # [KB]
  def bytes_to_kilobytes(byte)
    (byte / 1024.0).round(3)
  end
  # [MB]
  def bytes_to_megabytes(byte)
    (byte / (1024.0*1024.0)).round(3)
  end
  # [KB]
  def bytes_to_kilobytes_mac(byte)
    (byte / 1000.0).round(3)
  end
  # [MB]
  def bytes_to_megabytes_mac(byte)
    (byte / (1000.0*1000.0)).round(3)
  end

  # [byte]
  def get_total_size(images)
    total_size = 0
    images.each { |n| total_size += n.data.size }
    total_size
  end
end
