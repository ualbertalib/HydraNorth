class User < ActiveRecord::Base
 # Connects this user object to Hydra behaviors. 
 include Hydra::User
 include Sufia::User
 include Sufia::UserUsageStats


  attr_accessible :email, :password, :password_confirmation if Rails::VERSION::MAJOR < 4
# Connects this user object to Blacklights Bookmarks. 
  include Blacklight::User
  # Include default devise modules. Others available are:
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, 
         :confirmable, :lockable, :timeoutable,
         :omniauthable, :omniauth_providers => [:shibboleth]

  def self.from_omniauth(auth)
    where(provider: auth.provider, ccid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.email = auth.uid
      user.password = Devise.friendly_token[0,20]
      user.skip_confirmation!
      user.save!
    end
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  def admin?
    groups.include? 'admin'
  end

  def valid_password?(password)
    return super unless self.legacy_password.present?
    return false unless ((::Digest::MD5.hexdigest(password) == self.legacy_password) && 
                         (password.length >= 8))

    self.password = password
    self.legacy_password = nil
    self.save!
    true
  end

  def reset_password!(*args)
    self.legacy_password = nil
    super
  end

  # determines whether or not the user is allowed to authenticate using an ERA
  # username and password
  def can_use_legacy_login?
    !ccid.present?
  end
end
