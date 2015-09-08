class AddShouldForceLinkToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :should_force_link, :boolean, default: false, null: false
  end
end
