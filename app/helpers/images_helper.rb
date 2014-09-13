module ImagesHelper
  include ApplicationHelper

  # Count the size of all images in the storage.
  # @return [Float] The size in MB.
  def get_sizeof_all
    bytes_to_megabytes(Image.sum(:data_file_size))
  end
end
