class User < ActiveRecord::Base
 # Connects this user object to Hydra behaviors. 
 include Hydra::User
 include Sufia::User
 include Sufia::UserUsageStats


  attr_accessible :email, :password, :password_confirmation if Rails::VERSION::MAJOR < 4

  before_update :postpone_ccid_change_until_confirmation, if: :ccid_changed?

# Connects this user object to Blacklights Bookmarks. 
  include Blacklight::User
  # Include default devise modules. Others available are:
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, 
         :confirmable, :lockable, :timeoutable,
         :omniauthable, :omniauth_providers => [:shibboleth]

  def self.from_omniauth(auth)
    user = User.find_by_email(auth.uid) || User.find_by(ccid: auth.uid)
    if user and user.confirmed?
      user.provider = auth.provider
      user.ccid = auth.uid if (user.ccid != auth.uid)
      return user
    end
    where(provider: auth.provider, email: auth.uid).first_or_create do |user|
      user.skip_confirmation!
      user.email = auth.uid
      user.password = Devise.friendly_token[0,20]
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

  def postpone_ccid_change_until_confirmation
    @reconfirmation_required = true
    self.unconfirmed_ccid = self.ccid
    self.ccid = self.ccid_was
    self.confirmed_at = nil
  end

  def pending_ccid_confirmation?
    self.class.reconfirmable && unconfirmed_ccid.present?
  end

  # Send confirmation instructions by email
  def send_confirmation_instructions
    unless @raw_confirmation_token
      generate_confirmation_token!
    end

    if pending_ccid_confirmation? 
      opts = { to: email }
      send_devise_notification(:confirmation_instructions, @raw_confirmation_token, opts)
    end
    if @reconfirmation_required
      super
    end
  end

end
