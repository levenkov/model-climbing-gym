require_relative '../../lib/schedule_types'

class CreateVisitorProfiles < ActiveRecord::Migration[8.0]
  def up
    types = ScheduleTypes::ALL
    execute "CREATE TYPE schedule_type AS ENUM (#{types.map { |t| "'#{t}'" }.join(', ')});"

    create_table :visitor_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.decimal :visits_per_week, precision: 3, scale: 1, null: false
      t.column :schedule_type, :schedule_type, null: false
      t.boolean :has_own_shoes, null: false, default: false

      t.timestamps
    end
  end

  def down
    drop_table :visitor_profiles
    execute "DROP TYPE IF EXISTS schedule_type;"
  end
end
