class AddConfirmableToUsers < ActiveRecord::Migration
  def up
    add_column :users, :unconfirmed_email, :string
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :string
    add_column :users, :confirmation_sent_at, :datetime

    add_index :users, :confirmation_token, :unique => true

    User.update_all(:confirmed_at => Time.now) #your current data will be treated as if they have confirmed their account
  end

  def down
    remove_column :users, :unconfirmed_email, :confirmation_token, :confirmed_at, :confirmation_sent_at
  end
end
