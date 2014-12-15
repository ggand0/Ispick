class Image < ActiveRecord::Base
  has_one :feature, as: :featurable
  has_many :favored_images

  has_many :images_tags, dependent: :destroy
  has_many :tags, :through => :images_tags

  has_many :images_target_words, dependent: :destroy
  has_many :target_words, :through => :images_target_words


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

  TARGET_SITES = ['tumblr', 'anipic', 'nicoseiga', 'shushu', 'zerochan']
  TARGET_SITES_DISPLAY = ['tumblr', 'anime-pictures', 'nicoseiga', 'e-shuushuu', 'zerochan']

  # Set the default url of the paperclip attachment ('data' attribute)
  # @return [String]
  def set_default_url
    ActionController::Base.helpers.asset_path('default_image_thumb.png')
  end

  # Get the default url of the paperclip attachment ('data' attribute)
  def self.get_default_url
    '/assets/default_image_thumb.png'
  end

  # attachmentを削除し、ストレージにある画像ファイルも削除する
  # Destroys paperclip attachment, including image files in the storage
  def destroy_attachment
    # data.destroyは画像を削除するだけ、すなわちパスの指定は変更されない（デフォルトパスが指定されない）
    self.data.destroy
  end

  # Delete the image from the storage and set the default path instead.
  # ストレージから画像を削除し、デフォルトパスを指定する。
  def destroy_image_files
    tmp = self
    tmp.data = nil
    tmp.save
  end

  # Generate MD5 checksum value from the file.
  # 与えられたFileオブジェクトからMD5チェックサムを生成する
  # @param file [File] A file object that we need to get MD5 hash
  # @return [String] MD5 checksum value
  def generate_md5_checksum(file)
    self.md5_checksum = Digest::MD5.hexdigest(file.read)
  end

  # 与えられたsource urlから画像をダウンロードし、paperclip attachmentに保存する
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

  # 最近作成されたImageオブジェクトをlimit個取得してrelationオブジェクトを返す
  # Get images that is recently created.
  # @param limit [Integer] The number of images
  # @return [ActiveRecord::Relation::ActiveRecord_Relation_Image]
  def self.get_recent_images(limit, site=nil)
    if site
      Image.reorder("created_at DESC").where.not(data_updated_at: nil).limit(limit).where(site_name: site)
    else
      Image.reorder("created_at DESC").where.not(data_updated_at: nil).limit(limit)
    end
  end

  def self.get_recent_images_relation(images, site=nil)
    if site
      images.where(site_name: site)
    else
      images
    end
  end

  # 最近作成されたImageオブジェクトをlimit個取得してrelationオブジェクトを返す
  # Get images that is recently created.
  # @param limit [Integer] The number of images
  # @return [ActiveRecord::Relation::ActiveRecord_Relation_Image]
  def self.get_recent_n(limit)
    target_sites = ['anipic', 'shushu', 'zerochan']
    images = Image.where("site_name IN (?)", target_sites).limit(limit)
    images = images.reorder("created_at DESC").
      where.not(data_updated_at: nil).
      where.not(data_content_type: 'image/gif')
    images.uniq
  end

  # Create the list of image names from an Image relation object.
  # @param image [ActiveRecord::Relation::ActiveRecord_Relation_Image]
  # @return [Tempfile] A temporary file object is returned.
  def self.create_list_file(images)
    file = Tempfile.new("imagelist#{DateTime.now}")
    images.each do |image|
      #name = image.data.original_filename
      name = image.get_title
      file.write(name + "\s0")
      file.write "\n"
    end
    file
  end

  # Generate unique title string of the image
  # @return [String]
  def get_title
    title = "#{self.title}#{File.extname(self.data.path)}"
    title = title.gsub(/\//, '_') if title.include?("/")
    title = title.gsub(/\s+/, "_")
    title = Scrape.remove_nonascii(title)
    title
  end

  # Search images which is shown at user's home page.
  # @return [ActiveRecord::AssociationRelation]
  def self.search_images(query)
    Image.joins(:tags).where(tags: { name: query }).
      where.not(data_updated_at: nil).
      where.not(data_content_type: 'image/gif').
      references(:tags)
  end

  # Search images which is shown at user's home page.
  # @param query [Array] An array of tags used for search.
  # @return [ActiveRecord::AssociationRelation]
  def self.search_images_tags(query)
    Image.joins(:tags).where("tags.name IN (?)", query).
      where.not(data_updated_at: nil).
      where.not(data_content_type: 'image/gif').
      references(:tags)
  end

  # @param images [ActiveRecord::CollectionProxy]
  # @param date [Date] date
  # @return [ActiveRecord::CollectionProxy]
  def self.filter_by_date(images, date)
    images.where(created_at: date.to_datetime.utc..(date+1).to_datetime.utc)
  end

  # @param images [ActiveRecord::CollectionProxy]
  # @param date [Date] date
  # @return [ActiveRecord::CollectionProxy]
  def self.filter_by_date(images, site)
    images.where(site_name: site)
  end

  # Return images which is filtered by is_illust data.
  # How the filter is applied depends on the session[:illust] value.
  # イラストと判定されてるかどうかでフィルタをかけるメソッド。
  # @param images [ActiveRecord::Association::CollectionProxy]
  # @return [ActiveRecord::AssociationRelation] An association relation of DeliveredImage class.
  def self.filter_by_illust(images, illust)
    case illust
    when 'all'
      return images
    when 'illust'
      return images.where({ is_illust: true })
    when 'photo'
      return images.where({ is_illust: false })
    end
  end

  # Sort images by its original_favorite_count attribute.
  # @return [ActiveRecord::AssociationRelation]
  def self.sort_images(images, page)
    images = images.reorder('images.original_favorite_count desc')
    images.page(page).per(25)
  end

  # Sort images by its quality attribute.
  # @return [ActiveRecord::AssociationRelation]
  def self.sort_by_quality(images, page)
    images = images.reorder('quality desc')
    images.page(page).per(25)
  end

  def self.sort_by_posted_at(images)
  end
end
