class User < ActiveRecord::Base
  # Set this variabale true during testing to skip all callbacks.
  cattr_accessor :skip_callbacks

  # has_many uploaded images
  has_many :target_images, dependent: :destroy

  # has_many boards for storing clipped images
  has_many :image_boards, dependent: :destroy

  # has_many tags for making image feeds
  has_many :target_words_users
  has_many :target_words, :through => :target_words_users

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
    words = target_words.map{ |target_word| target_word.name }
    Image.joins(:target_words).where("target_words.name IN (?)", words).
      where.not(data_updated_at: nil).references(:target_words)
  end

  # For now, it's same as get_images method
  # @return [ActiveRecord::AssociationRelation]
  def get_images_all
    words = target_words.map{ |target_word| target_word.name }
    Image.joins(:target_words).where("target_words.name IN (?)", words).
      where.not(data_updated_at: nil).references(:target_words)
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


  # ===============================
  #  Authorization related methods
  # ===============================
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session['devise.facebook_data'] && session['devise.facebook_data']['extra']['raw_info']
        user.email = data['email']
      end
    end
  end

  #
  # emailを取得したい場合は、migrationにemailを追加する
  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(provider: auth.provider, uid: auth.uid).first
    unless user
      user = User.create(
        name:auth.extra.raw_info.name,
        provider:auth.provider,
        uid:auth.uid,
        email:auth.info.email,
        password:Devise.friendly_token[0,20]
      )
    end
    user
  end

  def self.find_for_twitter_oauth(auth, signed_in_resource=nil)
    user = User.where(provider: auth.provider, uid: auth.uid).first
    unless user
      user = User.create(
        name:     auth.info.nickname,
        provider: auth.provider,
        uid:      auth.uid,
        email:    User.create_unique_email,
        password: Devise.friendly_token[0,20]
      )
    end
    user
  end

  def self.find_for_tumblr_oauth(auth, signed_in_resource=nil)
    user = User.where(provider: auth.provider, uid: auth.uid).first
    unless user
      user = User.create(
        name:     auth.info.nickname,
        provider: auth.provider,
        uid:      auth.uid,
        email:    User.create_unique_email,
        password: Devise.friendly_token[0,20]
      )
    end
    user
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
