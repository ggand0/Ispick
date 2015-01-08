class Photo < ActiveRecord::Base
  has_many :tags

  # Aboid error by explicitly setting table name
  default_scope { order("#{table_name}.created_at DESC") }
  paginates_per 100

  has_attached_file :data,
    styles: {
      thumb: "300x",
      #thumb: { geometry: "300x300#", :processors => [:custom], :gif_first_frame_only => true },
      #thumb_gif: "300x300#",
      original: "600x800>"
    },
    default_url: lambda { |data| data.instance.set_default_url },
    use_timestamp: false
  after_post_process :save_image_dimensions

  def save_image_dimensions
    geo = Paperclip::Geometry.from_file(data.queued_for_write[:thumb])
    self.width = geo.width
    self.height = geo.height
  end

  before_destroy :destroy_attachment
  validates_uniqueness_of :src_url


  # Set the default url of the paperclip attachment ('data' attribute)
  # @return [String]
  def set_default_url
    ActionController::Base.helpers.asset_path('default_image_thumb.png')
  end

  # Get the default url of the paperclip attachment ('data' attribute)
  def self.get_default_url
    '/assets/default_image_thumb.png'
  end

  # Destroys paperclip attachment, also destroys actual image file in the storage
  def destroy_attachment
    self.data.destroy
  end

  def destroy_image_files
    tmp = self
    tmp.data = nil
    tmp.save
  end

  # Generate MD5 checksum value from the file.
  # @param file [File] A file object that we need to get MD5 hash
  # @return [String] MD5 checksum value
  def generate_md5_checksum(file)
    self.md5_checksum = Digest::MD5.hexdigest(file.read)
  end

  # Downloads image data from url and stores it as a paperclip attachment
  # @param url [String] The source url of an image
  # @return [String] A MD5 checksum string.
  def image_from_url(url)
    extension = url.match(/.(jpg|jpeg|pjpeg|png|x-png|gif)$/).to_s
    file = Tempfile.new(['image', extension])
    file.binmode
    open(URI.parse(url)) do |data|
      file.write data.read
    end
    file.rewind

    self.data = file
    generate_md5_checksum(file)
  end
end
