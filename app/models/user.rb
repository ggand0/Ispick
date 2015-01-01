class User < ActiveRecord::Base
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
    Image.select('images.id,posted_at,height,title,caption,data_file_name').joins(:tags).where("tags.name IN (?)", words).limit(10000).
      where.not(data_updated_at: nil).references(:tags)
  end

  # For now, it's same as get_images method
  # @return [ActiveRecord::AssociationRelation]
  def get_images_all
    words = tags.map{ |tag| tag.name }
    Image.joins(:tags).where("tags.name IN (?)", words).
      where.not(data_updated_at: nil).references(:tags)
  end

  # Get an optional ImageBoard instance by board_id.
  # そのUserオブジェクトに関連したImageBoardオブジェクトを取得する。
  # board_idが指定されない場合はimage_boards内の一番最初のオブジェクトを返す。
  # @param board_id [Integer] The image_board's id which you want to retrive
  # @return [ImageBoard]
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

  # Create a default image board and attach it to self instance.
  # 新しいレコードが作成された際に実行される。デフォルトのボード作成などを行う。
  def create_default
    # generate default image_board
    image_board = ImageBoard.create(name: 'Default')
    self.image_boards << image_board

    # generate default avatar
    self.avatar = File.open("#{Rails.root}/app/assets/images/icepick.png")
    self.save!
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

  # @return A string that provides an uuid.
  # 通常サインアップ時のuid用、Twitter OAuth認証時のemail用にuuidな文字列を生成
  def self.create_unique_string
    SecureRandom.uuid
  end

  # @return A random email address.
  # twitterではemailを取得できないので、適当に一意のemailを生成
  def self.create_unique_email
    User.create_unique_string + '@example.com'
  end

end
