require_relative '../../lib/simulation_statuses'

class CreateSimulations < ActiveRecord::Migration[8.0]
  def up
    statuses = SimulationStatuses::ALL
    execute "CREATE TYPE simulation_status AS ENUM (#{statuses.map { |s| "'#{s}'" }.join(', ')});"

    create_table :simulations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.column :status, :simulation_status, null: false, default: 'pending'
      t.jsonb :climber_params, null: false, default: {}
      t.jsonb :simulation_params, null: false, default: {}
      t.integer :progress_current, default: 0
      t.integer :progress_total, default: 0

      t.timestamps
    end
  end

  def down
    drop_table :simulations
    execute "DROP TYPE IF EXISTS simulation_status;"
  end
end
