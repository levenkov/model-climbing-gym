class CreateVisits < ActiveRecord::Migration[8.0]
  def change
    create_table :visits do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :checked_in_at, null: false
      t.datetime :checked_out_at

      t.timestamps
    end

    add_index :visits, :checked_in_at
    add_index :visits, :checked_out_at
  end
end
