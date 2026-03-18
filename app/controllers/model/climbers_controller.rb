module Model
  class ClimbersController < ApplicationController
    skip_before_action :verify_authenticity_token, only: []
    skip_after_action :verify_authorized, raise: false

    def index
      profiles = VisitorProfile.all

      @total_count = profiles.count
      @visits_values = profiles.pluck(:visits_per_week).map(&:to_f).sort
      @own_shoes_percent = @total_count.zero? ? 0 : (profiles.where(has_own_shoes: true).count * 100.0 / @total_count).round(1)
      @flexible_percent = @total_count.zero? ? 0 : (profiles.where(schedule_type: :flexible).count * 100.0 / @total_count).round(1)
    end
  end
end
