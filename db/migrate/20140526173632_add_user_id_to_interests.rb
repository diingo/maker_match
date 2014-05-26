class AddUserIdToInterests < ActiveRecord::Migration
  def change
    add_column :interests, :user_id, :integer
    add_index :interests, :user_id
  end
end
