class CreateGymStates < ActiveRecord::Migration[8.0]
  def change
    create_table :gym_states do |t|
      t.decimal :balance, precision: 12, scale: 2, null: false, default: 0
      t.integer :current_visitors, null: false, default: 0
      t.boolean :open, null: false, default: false
      t.datetime :recorded_at, null: false

      t.timestamps
    end

    add_index :gym_states, :recorded_at
  end
end
