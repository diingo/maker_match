class CreateUserInterestJoin < ActiveRecord::Migration
  def change
    create_table :user_interests do |t|
      t.references :user, index: true
      t.references :interest, index: true

      t.timestamps
    end
  end
end
