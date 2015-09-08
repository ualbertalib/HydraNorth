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

  scope :from_omniauth, ->(auth){ where('(email = ? OR ccid = ? OR unconfirmed_ccid = ?) AND (provider = ? OR provider is null)', 
                                         auth.uid, auth.uid, auth.uid, auth.provider).limit(1) }

  def self.create_from_omniauth(auth)
    create(
      email: auth.uid,
      password:Devise.friendly_token[0,20],
      should_force_link: true,
      confirmed_at: Time.now.utc,
      provider: auth.provider
    )
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

  def link_pending?
    self.should_force_link
  end

  def link!(other_account)
    self.ccid = other_account.email
    confirm_ccid! unless self == other_account
    self.provider = other_account.provider
    self.should_force_link = false
    save!
    return pending_ccid_confirmation?
  end

  def confirm_ccid!
      @reconfirmation_required = true
      self.unconfirmed_ccid = self.ccid
      self.ccid = self.ccid_was
      self.confirmed_at = nil
  end

  def associate_auth(auth)
    self.ccid = auth.uid
    self.provider = auth.provider
    save!
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

  def after_confirmation
    if self.unconfirmed_ccid.present?
      self.ccid = self.unconfirmed_ccid
      self.unconfirmed_ccid = nil
      save!
    end
  end

end
