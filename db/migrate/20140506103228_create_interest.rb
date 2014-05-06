class CreateInterest < ActiveRecord::Migration
  def change
    # TODO
    create_table :interests do |t|
  # TODO
      t.string :name
      t.string :expertise
      t.timestamps
    end
  end
end
