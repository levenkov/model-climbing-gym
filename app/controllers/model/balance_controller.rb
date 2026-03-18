module Model
  class BalanceController < BaseController
    def index
      @simulation = current_simulation
      @gym_states = @simulation.gym_states.order(:recorded_at)
      transactions = @simulation.financial_transactions
      @total_income = transactions.where(transaction_type: :income).sum(:amount)
      @total_expenses = transactions.where(transaction_type: :payment).sum(:amount)

      @income_by_category = transactions.where(transaction_type: :income).group(:category).sum(:amount)
      @expenses_by_category = transactions.where(transaction_type: :payment).group(:category).sum(:amount)
    end
  end
end
