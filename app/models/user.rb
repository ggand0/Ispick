class User < ActiveRecord::Base
  has_many :delivered_images
  has_many :target_images
  has_many :image_boards
  has_many :target_words

  devise :database_authenticatable, :omniauthable, :recoverable,
         :registerable, :rememberable, :trackable, :validatable

  has_attached_file :avatar,
    styles: { thumb: "x50" },
    use_timestamp: false
  #after_create :create_default_board
  #def create_default_board

  #end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session['devise.facebook_data'] && session['devise.facebook_data']['extra']['raw_info']
        user.email = data['email']
      end
    end
  end


  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(provider: auth.provider, uid: auth.uid).first
    unless user
      user = User.create(
        name:auth.extra.raw_info.name,
        provider:auth.provider,
        uid:auth.uid,
        email:auth.info.email, #emailを取得したい場合は、migrationにemailを追加してください。
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

  # 通常サインアップ時のuid用、Twitter OAuth認証時のemail用にuuidな文字列を生成
  def self.create_unique_string
    SecureRandom.uuid
  end

  # twitterではemailを取得できないので、適当に一意のemailを生成
  def self.create_unique_email
    User.create_unique_string + '@example.com'
  end

end
