class VisitorProfile < ApplicationRecord
  include SimpleEnumerable

  belongs_to :user
  belongs_to :simulation, optional: true

  simple_enum :schedule_type, :flexible, :fixed

  validates :visits_per_week, presence: true, numericality: { greater_than: 0 }
end
