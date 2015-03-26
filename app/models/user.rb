class User < ActiveRecord::Base
 # Connects this user object to Hydra behaviors. 
 include Hydra::User
 include Sufia::User
 include Sufia::UserUsageStats


  attr_accessible :email, :password, :password_confirmation if Rails::VERSION::MAJOR < 4
# Connects this user object to Blacklights Bookmarks. 
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, 
         :confirmable, :lockable, :timeoutable

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
    if self.legacy_password.present?
      if ::Digest::MD5.hexdigest(password) == self.legacy_password
        if password.length >= 8
          self.password = password
          self.legacy_password = nil
          self.save!
          true
        else
          false
        end
      else
        false
      end
    else
      super
    end
  end

  def reset_password!(*args)
    self.legacy_password = nil
    super
  end
  
end
