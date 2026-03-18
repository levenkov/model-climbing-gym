class GymState < ApplicationRecord
  belongs_to :simulation, optional: true

  validates :balance, presence: true
  validates :current_visitors, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :recorded_at, presence: true
end
