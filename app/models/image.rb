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
  # Destroys paperclip attachment, also destroys actual image file in the storage
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

  def self.get_popular_recent_images(limit)
    sites = ['anipic', 'shushu', 'zerochan']
    Image.where("site_name IN (?)", sites).where("original_favorite_count > (?)", 2).reorder("created_at DESC").where.not(data_updated_at: nil).limit(limit)
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
  def self.get_recent_n(limit=1000)
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

  # Create the list of image names from an Image relation object with multiple type of labels.
  # @param image [Array] Array of hashes: [{images: relation, label: 'string'},...]
  # @return [File]
  def self.create_list_file_labels(image_array, start=0)
    file = Tempfile.new("imagelist#{DateTime.now}")

    image_array.each_with_index do |hash, counter|
      hash[:images].each do |image|
        name = image.get_title
        file.write(name + "\s#{counter+start}")
        file.write "\n"
      end
    end
    file.flush
    file
  end

  def self.create_list_file_train_val(image_array, start=0)
    train = Tempfile.new("train#{DateTime.now}")
    val = Tempfile.new("val#{DateTime.now}")


    # Create another kind of array for convienience
    max = image_array[image_array.count-1][:label]
    tmp = []
    (0..max).each do |count|
      tmp.push(image_array.select { |element| element[:label] == count })
    end

    tmp.each_with_index do |arr, counter|
      #puts arr.count
      #puts arr.count/2.0
      puts arr.count
      #puts arr.map { |element| element[:label] }

      # Write former names to 'train' file, later names to 'val'
      arr.each_with_index do |hash, c|
        name = hash[:image].get_title


        if c < arr.count / 2.0
          train.write(name + "\s#{counter+start}")
          train.write "\n"
        else
          val.write(name + "\s#{counter+start}")
          val.write "\n"
        end
      end
    end



=begin
    image_array.each_with_index do |hash, counter|

      # Write former names to 'train' file, later names to 'val'
      hash[:images].each_with_index do |image, c|
        name = image.get_title

        if c <= hash[:images].count.keys.count / 2.0
          train.write(name + "\s#{counter+start}")
          train.write "\n"
        else
          val.write(name + "\s#{counter+start}")
          val.write "\n"
        end
      end
    end
=end

    train.flush
    val.flush
    [train, val]
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
  def self.search_images_tags(query, condition='or')
    # Use array to search with OR condition
    if condition == 'or'
      Image.joins(:tags).where("tags.name IN (?)", query).
        where.not(data_updated_at: nil).
        where.not(data_content_type: 'image/gif').
        references(:tags)

    # Dynamically merge relations and return the result
    elsif condition == 'and'
      relations = []
      query.each_with_index do |q, c|
        relations.push(Image.joins(:tags).where("tags.name = (?)", q))
      end

      condition = ""
      relations.each_with_index do |r, c|
        condition += "relations[#{c}]&"
      end

      #E.g. Image.where(id: (eval "i1 & i2")).
      Image.where(id: (eval condition[0..-2])).
        where.not(data_updated_at: nil).
        where.not(data_content_type: 'image/gif').
        references(:tags)
    end
  end

  # Get the common records of all given relations
  # @param relations [ActiveRecord::AssociationRelation_Image]
  # @return [ActiveRecord::AssociationRelation_Image]
  def self.and_search(relations)
    condition = ""
    relations.each_with_index do |r, c|
      condition += "relations[#{c}]&"
    end

    #E.g. Image.where(id: (eval "i1 & i2")).
    #Image.where(id: (eval condition[0..-2]))
    eval condition[0..-2]
  end

  # For research or debugging
  def self.search_images_custom(limit=nil, start=0)
    tags = Person.where(name_type: 'Character')
    tags = tags[start..start+limit-1] if limit
    puts tags.count
    tags = tags.map{ |person| person.name_roman }
    images_result = []
    counts = []

    tags.each_with_index do |tag, count|
      queries = [tag, 'single']

      # Get 'and' search result
      images = Image.joins(:tags).
        where('tags.name' => queries).
        group("images.id").having("count(*)= #{queries.count}")
      images = images.where.not(data_updated_at: nil)
      images.uniq!

      counts.push images.count
      images = images.map { |image| { image: image, label: count } }
      #images_result.push({ images: images, label: tag })
      images_result += images
    end

    # Remove duplicates again
    images_result.uniq_by! { |image| image[:image] }
    images_result
  end


  #=========================
  # Filter methods
  #=========================

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
