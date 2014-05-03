class Image < ActiveRecord::Base
  has_one :feature, as: :featurable
  has_and_belongs_to_many :tags
  belongs_to :delivered_image

  # 明示的にテーブル名を指定することでエラー回避
  default_scope { order("#{table_name}.created_at DESC") }
  paginates_per 100

	has_attached_file :data,
    styles: {
      thumb: "100x100#",
    },
    use_timestamp: false

  validates_uniqueness_of :src_url
  #validates_uniqueness_of :md5_checksum

  def generate_md5_checksum(file)
    self.md5_checksum = Digest::MD5.hexdigest(file.read)
  end

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
