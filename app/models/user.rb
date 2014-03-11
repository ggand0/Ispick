class User < ActiveRecord::Base
  has_many :delivered_images

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  #devise :trackable, :omniauthable, :omniauth_providers => [:facebook, :twitter]
  devise :database_authenticatable, :omniauthable, :recoverable,
         :registerable, :rememberable, :trackable, :validatable

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"]
      end
    end
  end


  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.create(name:auth.extra.raw_info.name,
                          provider:auth.provider,
                          uid:auth.uid,
                          # email:auth.info.email, #emailを取得したい場合は、migrationにemailを追加してください。
                          password:Devise.friendly_token[0,20]
      )
    end
    user
  end


  def self.find_for_twitter_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.create(name:auth.info.nickname,
                          provider:auth.provider,
                          uid:auth.uid,
                          # email:auth.extra.user_hash.email, #色々頑張りましたがtwitterではemail取得できません
                          password:Devise.friendly_token[0,20]
      )
    end
    user
  end

end
