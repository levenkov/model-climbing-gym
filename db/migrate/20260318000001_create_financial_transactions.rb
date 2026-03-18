require_relative '../../lib/financial_transaction_types'

class CreateFinancialTransactions < ActiveRecord::Migration[8.0]
  def up
    types = FinancialTransactionTypes::ALL
    execute "CREATE TYPE financial_transaction_type AS ENUM (#{types.map { |t| "'#{t}'" }.join(', ')});"

    create_table :financial_transactions do |t|
      t.column :transaction_type, :financial_transaction_type, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :category
      t.string :description
      t.date :date, null: false

      t.timestamps
    end

    add_index :financial_transactions, :transaction_type
    add_index :financial_transactions, :category
    add_index :financial_transactions, :date
  end

  def down
    drop_table :financial_transactions
    execute "DROP TYPE IF EXISTS financial_transaction_type;"
  end
end
