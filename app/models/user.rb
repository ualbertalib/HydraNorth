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

  scope :from_omniauth, ->(auth) { where('(email = ? OR ccid = ? OR unconfirmed_ccid = ?) AND (provider = ? OR provider is null)',
                                   User.uid_to_ccid(auth.uid), auth.uid, auth.uid, auth.provider).limit(1) }


  def self.create_from_omniauth(auth)
    raise(ArgumentError, 'UID is blank in Shibboleth authorization') unless auth.uid.present?

    ccid_email = uid_to_ccid(auth.uid)

    create(
      email: ccid_email,
      password:Devise.friendly_token[0,20],
      ccid: auth.uid,
      provider: auth.provider,
      should_force_link: true,
      confirmed_at: Time.now.utc
    )
  end

  # For masking the ID that we send to rollbar
  def id_as_hash
   Digest::SHA2.hexdigest("#{Rails.application.secrets.secret_key_base}_#{id}")
  end

  # for some reason, Sufia::User#name titleize's the user's display name.
  # (https://github.com/projecthydra/sufia/blob/master/sufia-models/app/models/concerns/sufia/user.rb#L96)
  # Shadow the method to undo this, so that "Raymond Luxury-Yacht" isn't
  # transformed into "Raymond Luxury Yacht", etc
  def name
    display_name || user_key
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
    return false unless (legacy_password_is?(password) &&
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
    self.ccid = other_account.ccid
    confirm_ccid! unless self == other_account
    self.provider = other_account.provider
    self.should_force_link = false
    save!
    return pending_ccid_confirmation?
  end

  def confirm_ccid!
      self.unconfirmed_ccid = self.ccid
      self.ccid = self.ccid_was
      self.confirmed_at = nil
      send_confirmation_instructions
  end

  def associate_auth(auth)
    self.ccid = auth.uid
    self.provider = auth.provider
    save!
  end

  def pending_ccid_confirmation?
    self.class.reconfirmable && unconfirmed_ccid.present?
  end

  def after_confirmation
    if self.unconfirmed_ccid.present?
      self.ccid = self.unconfirmed_ccid
      self.unconfirmed_ccid = nil
      save!
    end
  end

  def institutionally_authenticated?
    self.provider.present? && self.ccid.present?
  end

  def authenticating_institution
    # TODO this logic should be more generic and robust
    # but for now, assume user authenticated via the institution in their provider
    # field, if present. (this will be strictly true for UofA users as we force
    # them to CCID authenticate once they are associated)
    institutionally_authenticated? ? Hydranorth::AccessControls::InstitutionalVisibility::INSTITUTIONAL_PROVIDER_MAPPING[self.provider] : nil
  end

  private

  def self.uid_to_ccid(uid)
    unless (uid.end_with?('@ualberta.ca') || uid =~ /@/)
      return uid + '@ualberta.ca'
    else # at least it's something?
      return uid
    end
  end

  def legacy_password_is?(str)
    # the brcrypt engine overrides == to bcraypt the MD5 of the test str with
    # the correct salt
    BCrypt::Password.new(self.legacy_password) == ::Digest::MD5.hexdigest(str)
  end

end
