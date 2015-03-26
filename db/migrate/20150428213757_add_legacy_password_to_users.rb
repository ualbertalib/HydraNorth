class AddLegacyPasswordToUsers < ActiveRecord::Migration
  def change
    add_column :users, :legacy_password, :string
  end
end
