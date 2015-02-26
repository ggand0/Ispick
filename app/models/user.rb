class User < ActiveRecord::Base
  DEFAULT_DISPLAY_NUM = 10


  # Set this variabale true during testing to skip all callbacks.
  cattr_accessor :skip_callbacks

  # ==============
  #  Associations
  # ==============
  # Enable associating multiple social network accounts
  has_many :authorizations, dependent: :destroy

  # has_many uploaded images
  has_many :target_images, dependent: :destroy

  # has_many boards for storing clipped images
  has_many :image_boards, dependent: :destroy
  has_many :likes, dependent: :destroy, counter_cache: :likes_count

  # has_many tags for making image feeds
  has_many :tags_users, dependent: :destroy
  has_many :tags, :through => :tags_users

  # has_many recommended_tags for making image feeds
  has_many :recommended_tags_users, dependent: :destroy
  has_many :recommended_tags, :through => :recommended_tags_users

  # has_many target_sites for filtering image feeds by default
  has_many :target_sites_users, dependent: :destroy
  has_many :target_sites, :through => :target_sites_users


  # ================
  #  Other settings
  # ================
  # devise configuration
  devise :database_authenticatable, :omniauthable, :recoverable,
         :registerable, :rememberable, :trackable, :validatable, :omniauth_providers=>[:tumblr,:twitter,:facebook]

  # paperclip configuration: thumbnail size, etc.
  has_attached_file :avatar,
    styles: { thumb: "x50" },
    default_url: lambda { |data| data.instance.set_default_url },
    use_timestamp: false

  # callbacks and validations
  after_create :create_default
  validates :name, presence: true

  # ==================
  #  Instance methods
  # ==================
  # Scrape and deliver images right after a new tag is created by an user.
  # @param target_word [TargetWord]
  def search_keyword(target_word)
    Resque.enqueue(SearchImages, self.id, target_word.id)
  end

  # Get images which is shown at user's home page.
  # @return [ActiveRecord::AssociationRelation]
  def get_images
    words = tags.map{ |tag| tag.name }
    #Image.joins(:tags).where("tags.name IN (?)", words).limit(10000).
    Image.select('images.id,posted_at,width,height,title,caption,data_file_name').joins(:tags).where("tags.name IN (?)", words).limit(10000).
      where.not(data_updated_at: nil).references(:tags)
  end

  # For now, it's same as get_images method
  # @return [ActiveRecord::AssociationRelation]
  def get_images_all
    words = tags.map{ |tag| tag.name }
    Image.joins(:tags).where("tags.name IN (?)", words).
      where.not(data_updated_at: nil).references(:tags)
  end

  # Get an optional ImageBoard instance associated with this User instance, by board_id.
  # If board_id was not assigned, returns the first object of self.image_boards.
  # @param board_id [Integer] The image_board's id which you want to retrive
  # @return [ImageBoard] An ImageBoard object
  def get_board(board_id=nil)
    if board_id.nil?
      board = image_boards.first
    else
      board = image_boards.find(board_id)
    end
  end

  # @return The path where default thumbnail file is.
  def set_default_url
    ActionController::Base.helpers.asset_path('default_user_thumb.png')
  end

  # Create default objects and attach them to a newly created user.
  # E.g. Creating a default image board and attach it to self instance.
  def create_default
    # generate default image_board
    image_board = ImageBoard.create(name: 'Default')
    self.image_boards << image_board

    # generate default avatar
    self.avatar = File.open("#{Rails.root}/app/assets/images/icepick.png")
    self.save!

    # Add all TargetSite records as default
    TargetSite.all.each do |site|
      self.target_sites << site
    end
  end



  # ===============================
  #  Authorization related methods
  # ===============================

  # Called from omniauth_callback_controller.
  # @param auth [OmniAuth::AuthHash]
  # @param current_user [User]
  # @return [User]
  def self.from_omniauth(auth, current_user)
    authorization = Authorization.where(
      :provider => auth.provider,
      :uid => auth.uid.to_s,
      :token => auth.credentials.token,
      :secret => auth.credentials.secret
    ).first_or_initialize

    if authorization.user.blank?
      user = current_user.nil? ? User.where('email = ?', auth["info"]["email"]).first : current_user
      unless user
        begin
          user = User.create(
            #name:     auth.info.nickname,
            name:     User.get_user_name(auth),
            provider: auth.provider,
            uid:      auth.uid,
            email:    User.get_email(auth),
            password: Devise.friendly_token[0,20]
          )
        rescue => e
          return
        end
      end

      authorization.user_name = User.get_user_name(auth)
      authorization.user = user
      authorization.save
    end
    authorization.user
  end

  def self.get_user_name(auth)
    if auth.provider == 'facebook'
      "#{auth.info.first_name} #{auth.info.last_name}"
    else
      auth.info.nickname
    end
  end

  def self.get_email(auth)
    auth.provider == 'twitter' ? User.create_unique_email : auth.info.email
  end

  # Create uuid string for general signup use or dummy email string when Twitter OAuth
  # @return A string that provides an uuid.
  def self.create_unique_string
    SecureRandom.uuid
  end

  # Since twitter API doesn't provide email fetch, create a dummy unique string and assign it.
  # @return A random email address.
  def self.create_unique_email
    User.create_unique_string + '@example.com'
  end


  # ====================
  #   Recommendation
  # ====================
  def get_coocurrence_tags
    #images = Image.get_popular_recent_images(10000)
    _tags = {}

    tags.each do |tag|
      images = tag.get_images
      images = images.limit(100)

      # Check for co-occurrence word by word
      images.each do |image|
        image.tags.each do |_tag|
          if _tags.has_key?(_tag.name)
            _tags[_tag.name] += 1
          else
            _tags[_tag.name] = 1
          end
        end
      end
    end

    # Eliminate the existing tags
    _tags.reject!{ |k, v| v.to_i<=1 or self.tags.where(name: k).count > 0 or self.recommended_tags.where(name: k).count > 0 }

    #puts "User: #{self.id}"
    #puts "Tags: #{self.tags.inspect}"
    #puts "Co-occurred  tags:"
    #puts _tags.delete_if{|t| t.to_i<=1}.inspect

    _tags.each do |name, value|
      recommended_tag = RecommendedTag.where(name: name).first
      if recommended_tag.nil?
        recommended_tag = RecommendedTag.new(name: name)
      end

      self.recommended_tags << recommended_tag
      #RecommendedTag.reset_counters(recommended_tag.id, :images)
    end
  end

end
