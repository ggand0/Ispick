module ApplicationHelper
  def bytes_to_kilobytes(byte)
    (byte / 1024.0).round(3)
  end
  def bytes_to_megabytes(byte)
    (byte / (1024.0*1024.0)).round(3)
  end
  def bytes_to_kilobytes_mac(byte)
    (byte / 1000.0).round(3)
  end
  def bytes_to_megabytes_mac(byte)
    (byte / (1000.0*1000.0)).round(3)
  end
end
