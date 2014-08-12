class User < ActiveRecord::Base
  cattr_accessor :skip_callbacks

  has_many :delivered_images, dependent: :destroy
  has_many :target_images, dependent: :destroy
  has_many :image_boards, dependent: :destroy

  # 登録タグをhas_manyしている
  # タグが追加されたらcallbackを呼んで抽出・配信処理を行う
  has_many :target_words_users
  has_many :target_words, :through => :target_words_users

  devise :database_authenticatable, :omniauthable, :recoverable,
         :registerable, :rememberable, :trackable, :validatable

  has_attached_file :avatar,
    styles: { thumb: "x50" },
    default_url: lambda { |data| data.instance.set_default_url },
    use_timestamp: false

  after_create :create_default
  validates :name, presence: true

  # Scrape and deliver images right after a new tag is created by an user
  # @param target_word [TargetWord]
  def search_keyword(target_word)
    Resque.enqueue(SearchImages, self.id, target_word.id)
  end

  def get_delivered_images
    delivered_images.
      where.not(images: { site_name: 'twitter' }).
      joins(:image).
      reorder('created_at DESC')
  end

  # @param delivered_images [ActiveRecord::CollectionProxy]
  # @param date [Date] date
  # @return [ActiveRecord::CollectionProxy]
  def self.filter_by_date(delivered_images, date)
    delivered_images.where(created_at: date.to_datetime.utc..(date+1).to_datetime.utc)
  end

  def sort_delivered_images(delivered_images)
    delivered_images = delivered_images.includes(:image).
      reorder('images.favorites desc').references(:images)
    delivered_images.page(params[:page]).per(25)
  end

  def sort_by_quality(delivered_images)
    delivered_images = delivered_images.includes(:image).
      reorder('images.quality desc').references(:images)
    delivered_images.page(params[:page]).per(25)
  end

  # @return The path where default thumbnail file is.
  def set_default_url
    ActionController::Base.helpers.asset_path('default_user_thumb.png')
  end

  # Create a default image board and attach it to self instance.
  def create_default
    # generate default image_board
    image_board = ImageBoard.create(name: 'Default')
    self.image_boards << image_board

    # generate default avatar
    self.avatar = File.open("#{Rails.root}/app/assets/images/icepick.png")
    self.save!
  end


  # =========================
  # Authorization related
  # =========================

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
