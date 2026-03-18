class Simulation < ApplicationRecord
  include SimpleEnumerable

  simple_enum :status, *SimulationStatuses::ALL, default: :pending

  belongs_to :user
  has_many :visitor_profiles, dependent: :destroy
  has_many :visits, dependent: :destroy
  has_many :financial_transactions, dependent: :destroy
  has_many :gym_states, dependent: :destroy

  validates :name, presence: true
end
