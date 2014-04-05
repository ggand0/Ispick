class Image < ActiveRecord::Base
  has_one :feature, as: :featurable
  has_many :tags

  # 明示的にテーブル名を指定することでエラー回避
  default_scope { order("#{table_name}.created_at DESC") }
  paginates_per 100

	has_attached_file :data,
    styles: {
      thumb: "100x100#",
      small: "150x150>",
      medium: "200x200" },
    use_timestamp: false

  validates_uniqueness_of :src_url
  validates_uniqueness_of :md5_checksum
  #before_validation_on_create :generate_md5_checksum
  before_validation(on: :create) do
    #generate_md5_checksum()
  end

  def generate_md5_checksum(file)
    #self.md5_checksum = Digest::MD5.hexdigest(data.read) if self.data
    self.md5_checksum = Digest::MD5.hexdigest(file.read)
  end

	def image_from_url(url)
    #self.data = URI.parse(url)

    #file = Tempfile.new([basename, extname])
    file = Tempfile.new('image')
    file.binmode
    open(URI.parse(url)) do |data|
      file.write data.read
    end
    file.rewind

    self.data = file
    generate_md5_checksum(file)
	end
end
