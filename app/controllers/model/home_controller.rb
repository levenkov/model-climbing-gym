module Model
  class HomeController < ApplicationController
    skip_after_action :verify_authorized, raise: false

    def index
      @climber_count = VisitorProfile.count
      @visit_count = Visit.count
      @transaction_count = FinancialTransaction.count
      @simulation_days = GymState.count
    end
  end
end
