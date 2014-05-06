class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.references :users, index: true
      t.references :groups, index: true

      t.timestamps
    end
  end
end
