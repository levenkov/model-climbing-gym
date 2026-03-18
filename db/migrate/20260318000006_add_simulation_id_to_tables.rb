class AddSimulationIdToTables < ActiveRecord::Migration[8.0]
  def change
    add_reference :visitor_profiles, :simulation, null: true, foreign_key: true
    add_reference :visits, :simulation, null: true, foreign_key: true
    add_reference :financial_transactions, :simulation, null: true, foreign_key: true
    add_reference :gym_states, :simulation, null: true, foreign_key: true
  end
end
