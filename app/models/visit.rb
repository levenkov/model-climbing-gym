class Visit < ApplicationRecord
  belongs_to :user

  validates :checked_in_at, presence: true
  validate :checked_out_at_after_checked_in_at

  private

  def checked_out_at_after_checked_in_at
    return if checked_out_at.blank?

    if checked_out_at <= checked_in_at
      errors.add(:checked_out_at, "must be after check-in time")
    end
  end
end
