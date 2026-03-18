module Model
  class DaysController < BaseController
    def show
      @simulation = current_simulation
      @date = Date.parse(params[:id])
      @visits = @simulation.visits.where('checked_in_at::date = ?', @date).includes(:user)

      @total_visits = @visits.count
      @peak_visitors = calculate_peak_visitors
      @peak_hour = @peak_hour_value

      @hourly_presence = (0..23).map do |hour|
        time = @date.to_time.change(hour: hour, min: 30)
        count = @visits.count { |v| v.checked_in_at <= time && (v.checked_out_at.nil? || v.checked_out_at >= time) }
        [hour, count]
      end

      transactions = @simulation.financial_transactions.where(date: @date)
      @income = transactions.where(transaction_type: :income)
      @expenses = transactions.where(transaction_type: :payment)
      @total_income = @income.sum(:amount)
      @total_expenses = @expenses.sum(:amount)

      @income_by_category = @income.group(:category).sum(:amount)
      @expenses_by_category = @expenses.group(:category).sum(:amount)
    end

    private

    def calculate_peak_visitors
      max = 0
      @peak_hour_value = 0
      (0..23).each do |hour|
        time = @date.to_time.change(hour: hour, min: 30)
        count = @visits.count { |v| v.checked_in_at <= time && (v.checked_out_at.nil? || v.checked_out_at >= time) }
        if count > max
          max = count
          @peak_hour_value = hour
        end
      end
      max
    end
  end
end
