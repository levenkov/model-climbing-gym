class FinancialTransaction < ApplicationRecord
  include SimpleEnumerable

  belongs_to :simulation, optional: true

  simple_enum :transaction_type, :income, :payment

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
end
