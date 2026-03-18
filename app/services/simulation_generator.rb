class SimulationGenerator
  DEFAULTS = {
    days: 30,
    start_date: Date.today,
    initial_balance: 0,

    # Gym operating hours
    open_hour: 10,
    close_hour: 22,

    # Visit duration in hours (normal distribution)
    visit_duration_mean: 2.0,
    visit_duration_std: 0.5,
    visit_duration_min: 0.5,
    visit_duration_max: 4.0,

    # Fixed schedule visitors arrive between these hours
    fixed_arrive_from: 18,
    fixed_arrive_to: 20,

    # Pricing
    visit_fee: 500,
    shoe_rental_fee: 200,

    # Monthly expenses
    rent: 300_000,
    electricity: 30_000,
    water: 10_000,
    other_bills: 15_000,
    staff_salaries: 200_000
  }.freeze

  EXPENSE_CATEGORIES = %i[rent electricity water other_bills staff_salaries].freeze

  def initialize(**params)
    @params = DEFAULTS.merge(params)
    @balance = @params[:initial_balance].to_f
    @profiles = VisitorProfile.includes(:user).to_a
  end

  def call
    start = @params[:start_date]
    days = @params[:days]

    days.times do |day_offset|
      date = start + day_offset
      simulate_day(date)
      print '.'
    end

    puts
  end

  private

  def simulate_day(date)
    # Pay monthly expenses on the 1st
    if date.day == 1
      pay_monthly_expenses(date)
    end

    visitors_today = select_visitors_for_day(date)

    visitors_today.each do |profile|
      check_in_time = random_check_in_time(date, profile)
      duration = random_duration
      check_out_time = check_in_time + duration.hours

      # Cap at closing time
      closing = date.to_time.change(hour: @params[:close_hour])
      check_out_time = closing if check_out_time > closing

      visit = Visit.create!(
        user: profile.user,
        checked_in_at: check_in_time,
        checked_out_at: check_out_time
      )

      record_visit_income(date, profile)
    end

    # Record end-of-day gym state
    record_gym_state(date)
  end

  def select_visitors_for_day(date)
    @profiles.select do |profile|
      # visits_per_week probability: e.g. 3.0 visits/week = 3.0/7 daily probability
      daily_probability = profile.visits_per_week.to_f / 7.0
      rand < daily_probability
    end
  end

  def random_check_in_time(date, profile)
    if profile.flexible?
      hour = rand(@params[:open_hour]...@params[:close_hour] - 1)
      minute = rand(0..59)
    else
      hour = rand(@params[:fixed_arrive_from]..@params[:fixed_arrive_to])
      minute = rand(0..59)
    end
    date.to_time.change(hour: hour, min: minute)
  end

  def random_duration
    min = @params[:visit_duration_min]
    max = @params[:visit_duration_max]
    loop do
      value = normal_random(@params[:visit_duration_mean], @params[:visit_duration_std])
      return value.round(1) if value >= min && value <= max
    end
  end

  def record_visit_income(date, profile)
    # Visit fee
    @balance += @params[:visit_fee]
    FinancialTransaction.create!(
      transaction_type: :income,
      amount: @params[:visit_fee],
      category: 'visit_fee',
      description: "Visit fee: #{profile.user.name}",
      date: date
    )

    # Shoe rental for those without own shoes
    unless profile.has_own_shoes
      @balance += @params[:shoe_rental_fee]
      FinancialTransaction.create!(
        transaction_type: :income,
        amount: @params[:shoe_rental_fee],
        category: 'shoe_rental',
        description: "Shoe rental: #{profile.user.name}",
        date: date
      )
    end
  end

  def pay_monthly_expenses(date)
    EXPENSE_CATEGORIES.each do |category|
      amount = @params[category]
      next if amount.nil? || amount.zero?

      @balance -= amount
      FinancialTransaction.create!(
        transaction_type: :payment,
        amount: amount,
        category: category.to_s,
        description: "Monthly #{category.to_s.humanize.downcase}",
        date: date
      )
    end
  end

  def record_gym_state(date)
    # Count visitors present at peak hour (19:00)
    peak_time = date.to_time.change(hour: 19)
    current_visitors = Visit.where('checked_in_at <= ? AND checked_out_at >= ?', peak_time, peak_time).count

    GymState.create!(
      balance: @balance,
      current_visitors: current_visitors,
      open: true,
      recorded_at: date.to_time.end_of_day
    )
  end

  def normal_random(mean, std)
    u1 = rand
    u2 = rand
    z = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2.0 * Math::PI * u2)
    mean + z * std
  end
end
