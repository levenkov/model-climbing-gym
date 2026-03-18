module Model
  class BalanceController < ApplicationController
    skip_before_action :verify_authenticity_token, only: []
    skip_after_action :verify_authorized, raise: false

    def index
      @gym_states = GymState.order(:recorded_at)
      @total_income = FinancialTransaction.where(transaction_type: :income).sum(:amount)
      @total_expenses = FinancialTransaction.where(transaction_type: :payment).sum(:amount)

      @income_by_category = FinancialTransaction.where(transaction_type: :income)
        .group(:category).sum(:amount)
      @expenses_by_category = FinancialTransaction.where(transaction_type: :payment)
        .group(:category).sum(:amount)
    end
  end
end
