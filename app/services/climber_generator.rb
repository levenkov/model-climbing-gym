class ClimberGenerator
  DEFAULTS = {
    count: 100,

    # Normal distribution parameters for visits per week
    visits_per_week_mean: 3.0,
    visits_per_week_std: 1.5,
    visits_per_week_min: 0.1,
    visits_per_week_max: 7,

    # Percentage of climbers with flexible schedule (0.0 - 1.0)
    flexible_schedule_ratio: 0.4,

    # Percentage of climbers who own their own shoes (0.0 - 1.0)
    own_shoes_ratio: 0.3
  }.freeze

  def initialize(simulation:, **params)
    @simulation = simulation
    @params = DEFAULTS.merge(params)
  end

  def call(&on_progress)
    @params[:count].times.map do |i|
      user = generate_one
      on_progress&.call(i + 1)
      user
    end
  end

  private

  def generate_one
    user = User.create!(
      name: Faker::Name.name,
      email: Faker::Internet.unique.email,
      password: SecureRandom.hex(16)
    )

    user.create_visitor_profile!(
      simulation: @simulation,
      visits_per_week: random_visits_per_week,
      schedule_type: random_schedule_type,
      has_own_shoes: rand < @params[:own_shoes_ratio]
    )

    print '.'
    user
  end

  # Truncated normal: reject and resample values outside [min, max]
  def random_visits_per_week
    min = @params[:visits_per_week_min]
    max = @params[:visits_per_week_max]
    loop do
      value = normal_random(@params[:visits_per_week_mean], @params[:visits_per_week_std]).round(1)
      return value if value >= min && value <= max
    end
  end

  def random_schedule_type
    rand < @params[:flexible_schedule_ratio] ? :flexible : :fixed
  end

  # Box-Muller transform for normal distribution
  def normal_random(mean, std)
    u1 = rand
    u2 = rand
    z = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2.0 * Math::PI * u2)
    mean + z * std
  end
end
