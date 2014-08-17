class Image < ActiveRecord::Base
  has_one :feature, as: :featurable
  has_many :delivered_images, dependent: :destroy
  has_many :images_tags
  has_many :tags, :through => :images_tags
  has_many :images_target_words
  has_many :images, :through => :images_target_words


  # 明示的にテーブル名を指定することでエラー回避
  default_scope { order("#{table_name}.created_at DESC") }
  paginates_per 100

	has_attached_file :data,
    styles: { thumb: "300x300#", medium: "600x800>" },
    default_url: lambda { |data| data.instance.set_default_url},
    use_timestamp: false

  # レコード削除時に画像ファイルも消す
  before_destroy :destroy_attachment
  validates_uniqueness_of :src_url

  # @return [String] デフォルトでattachmentに設定される画像のpath
  def set_default_url
    ActionController::Base.helpers.asset_path('default_image_thumb.png')
  end

  # Destroys paperclip attachment
  def destroy_attachment
    self.data.destroy
  end

  # Generate MD5 checksum value from the file
  # @param file [File] MD5を得たいファイルオブジェクト
  # @return [String] MD5 checksum value
  def generate_md5_checksum(file)
    self.md5_checksum = Digest::MD5.hexdigest(file.read)
  end

  # Downloads image data from url and stores it as a paperclip attachment
  # @param url [String] 画像のソースURL
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
