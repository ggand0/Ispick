module ApplicationHelper

  # Convert a Rails flash type to Bootstrap one
  # @return [String] Bootstrap flash type string
  def bootstrap_class_for flash_type
    case flash_type
      when :success
        "alert-success"
      when :error
        "alert-error"
      when :alert
        "alert-block"
      when :notice
        "alert-info"
      else
        flash_type.to_s
    end
  end

  # Convert byte to kilobyte
  # @param [Integer] byte[B]
  # @return [Integer] kilobyte[KB]
  def bytes_to_kilobytes(byte)
    return 0 unless byte      # Return 0 if it's nil
    (byte / 1024.0).round(3)
  end

  # Convert byte to megabyte
  # @param [Integer] byte[B]
  # @return [Integer] megabyte[MB]
  def bytes_to_megabytes(byte)
    return 0 unless byte
    (byte / (1024.0*1024.0)).round(3)
  end

  # Convert byte to kilobyte for mac
  # @param [Integer] byte[B]
  # @return [Integer] kilobyte[KB]
  def bytes_to_kilobytes_mac(byte)
    return 0 unless byte
    (byte / 1000.0).round(3)
  end

  # Convert byte to megabyte for mac
  # @param [Integer] byte[B]
  # @return [Integer] megabyte[MB]
  def bytes_to_megabytes_mac(byte)
    return 0 unless byte
    (byte / (1000.0*1000.0)).round(3)
  end


  # Calculate total size in the storage from given relation object or array.
  # @param [ActiveRecord::Relation] A relation object of Image related model
  # @return [Integer] Sum of file size in byte
  def get_total_size(images)
    return 0 if images.nil?

    total_size = 0
    images.each do |i|
      next if i.nil?
      total_size += i.data.size if i.data and i.data.size
    end
    total_size
  end

  # @param datetime [DateTime]
  # @return [DateTime]
  def utc_to_jst(datetime)
    datetime ? datetime.in_time_zone('Asia/Tokyo') : 'unknown'
  end

  # @param datetime [DateTime]
  # @return [String]
  def get_time_string(datetime)
    datetime ? datetime.strftime("%d %B %Y, %H:%M") : 'unknown'
  end

  # @param datetime [DateTime]
  # @return [String]
  def get_jst_string(datetime)
    datetime ? get_time_string(utc_to_jst(datetime)) : 'unknown'
  end

  # @param datetime [DateTime]
  # @return [String]
  def get_time_string_ja(datetime)
    datetime ? datetime.strftime("%Y年%m月%d日%H時%M分") : 'unknown'
  end

  # @param datetime [DateTime]
  # @return [String]
  def get_jst_string_ja(datetime)
    datetime ? get_time_string_ja(utc_to_jst(datetime)) : 'unknown'
  end
end
