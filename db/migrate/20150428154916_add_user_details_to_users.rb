class AddUserDetailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :description, :text
    add_column :users, :institution, :string
    add_column :users, :fax, :string
  end
end
