class AddLockableToDevise < ActiveRecord::Migration
  def change
    add_column :users, :locked_at, :datetime
  end
end
