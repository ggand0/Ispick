class User < ActiveRecord::Base
  # Set this variabale true during testing.
  cattr_accessor :skip_callbacks

  has_many :images, dependent: :destroy
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
=begin
    images = target_words.first.images
    target_words.all.each_with_index do |target_word, count|
      next if count == 0
      #images = images.merge(target_word.images)
      #images += target_word.images
      images = images + target_word.images
    end

    images = Image.where("id IN (#{images.map(&:id).join(',')})")

    images.
      where.not(is_illust: nil).        # Already downloaded
      where.not(site_name: 'twitter').
      #reorder('posted_at DESC')         # Sort by posted_at value
      reorder('created_at DESC')         # Sort by posted_at value
      .limit(200)
=end
    words = target_words.map{ |target_word| target_word.word }
    Image.joins(:target_words).where("target_words.word IN (?)", words).references(:target_words)
  end

  # @return [ActiveRecord::AssociationRelation]
  def get_images_all
    images.joins(:image).order('images.posted_at')
  end

  # @param images [ActiveRecord::CollectionProxy]
  # @param date [Date] date
  # @return [ActiveRecord::CollectionProxy]
  def self.filter_by_date(images, date)
    images.where(created_at: date.to_datetime.utc..(date+1).to_datetime.utc)
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

  # @return [ActiveRecord::AssociationRelation]
  def self.sort_images(images, page)
    images = images.reorder('images.favorites desc')
    images.page(page).per(25)
  end

  # @return [ActiveRecord::AssociationRelation]
  def self.sort_by_quality(images, page)
    images = images.includes(:image).
      reorder('images.quality desc').references(:images)
    #images.page(params[:page]).per(25)
    images.page(page).per(25)
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

    # generate default target_word
    #target_word = TargetWord.where(word: '鹿目まどか').first
    #target_word = TargetWord.create(word: '鹿目まどか') if target_word.nil?
    #self.target_words << target_word

    # generate default avatar
    self.avatar = File.open("#{Rails.root}/app/assets/images/icepick.png")
    self.save!
  end

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
