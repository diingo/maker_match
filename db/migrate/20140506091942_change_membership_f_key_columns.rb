class ChangeMembershipFKeyColumns < ActiveRecord::Migration
  def change
    # TODO
    remove_column :memberships, :users_id, :integer
    remove_column :memberships, :groups_id, :integer
    add_column :memberships, :group_id, :integer
    add_column :memberships, :user_id, :integer
    # these caused an error somehow
    # remove_index :memberships, :groups_id
    # remove_index :memberships, :users_id
    add_index :memberships, :group_id
    add_index :memberships, :user_id
  end
end
