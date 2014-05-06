class CreateInvite < ActiveRecord::Migration
  def change
    # TODO
    create_table :invites do |t|
  # TODO
      t.integer :invitee_id
      t.integer :inviter_id
      t.string :response
      t.references :group, index: true
      t.timestamps
    end
  end
end
