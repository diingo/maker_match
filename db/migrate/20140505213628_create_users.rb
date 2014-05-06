class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :github_login
      t.boolean :remote
      t.integer :latitude
      t.integer :longitude

      t.timestamps
    end
  end
end
