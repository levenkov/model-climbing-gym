namespace :simulation do
  desc 'Run a full simulation (generate climbers + simulate days)'
  task run: :environment do
    required = ENV.slice('COUNT', 'DAYS')
    if required.size < 2
      puts <<~USAGE
        Usage: bin/rails simulation:run COUNT=100 DAYS=90 [NAME="My Simulation"]
               [MEAN=3.0] [STD=1.5] [FLEXIBLE=0.4] [SHOES=0.3]
               [START_DATE=2026-01-01] [BALANCE=0]
               [VISIT_FEE=500] [SHOE_FEE=200]
               [RENT=300000] [ELECTRICITY=30000] [WATER=10000]
               [OTHER_BILLS=15000] [SALARIES=200000]

        Required:
          COUNT       Number of climbers to generate
          DAYS        Number of days to simulate

        Climber generation:
          MEAN        Mean visits per week, normal distribution (default: 3.0)
          STD         Standard deviation for visits per week (default: 1.5)
          FLEXIBLE    Ratio with flexible work schedule, 0.0-1.0 (default: 0.4)
          SHOES       Ratio who own climbing shoes, 0.0-1.0 (default: 0.3)

        Simulation:
          NAME        Simulation name (default: "CLI Simulation <timestamp>")
          START_DATE  First day, YYYY-MM-DD (default: today)
          BALANCE     Initial gym balance (default: 0)
          VISIT_FEE   Fee per visit (default: 500)
          SHOE_FEE    Shoe rental fee per visit (default: 200)
          RENT        Monthly rent (default: 300000)
          ELECTRICITY Monthly electricity bill (default: 30000)
          WATER       Monthly water bill (default: 10000)
          OTHER_BILLS Monthly other bills (default: 15000)
          SALARIES    Monthly staff salaries (default: 200000)

        Example:
          bin/rails simulation:run COUNT=50 DAYS=90 START_DATE=2026-01-01 BALANCE=500000
      USAGE
      exit
    end

    user = User.find(User::ROOT_USER_ID)
    name = ENV['NAME'] || "CLI Simulation #{Time.current.strftime('%Y-%m-%d %H:%M')}"

    simulation = Simulation.create!(
      user: user,
      name: name,
      climber_params: {
        count: ENV['COUNT'].to_i,
        visits_per_week_mean: (ENV['MEAN'] || 3.0).to_f,
        visits_per_week_std: (ENV['STD'] || 1.5).to_f,
        flexible_schedule_ratio: (ENV['FLEXIBLE'] || 0.4).to_f,
        own_shoes_ratio: (ENV['SHOES'] || 0.3).to_f
      },
      simulation_params: {
        days: ENV['DAYS'].to_i,
        start_date: ENV['START_DATE'] || Date.today.to_s,
        initial_balance: (ENV['BALANCE'] || 0).to_f,
        visit_fee: (ENV['VISIT_FEE'] || 500).to_f,
        shoe_rental_fee: (ENV['SHOE_FEE'] || 200).to_f,
        rent: (ENV['RENT'] || 300_000).to_f,
        electricity: (ENV['ELECTRICITY'] || 30_000).to_f,
        water: (ENV['WATER'] || 10_000).to_f,
        other_bills: (ENV['OTHER_BILLS'] || 15_000).to_f,
        staff_salaries: (ENV['SALARIES'] || 200_000).to_f
      }
    )

    puts "Created simulation: #{simulation.name} (ID: #{simulation.id})"

    puts "Generating #{simulation.climber_params['count']} climbers..."
    simulation.update!(status: :generating_climbers)
    ClimberGenerator.new(simulation: simulation, **simulation.climber_params.symbolize_keys).call
    puts

    puts "Simulating #{simulation.simulation_params['days']} days..."
    simulation.update!(status: :simulating)
    SimulationGenerator.new(simulation: simulation, **simulation.simulation_params.symbolize_keys).call

    simulation.update!(status: :completed)
    puts "Done. #{simulation.visits.count} visits, #{simulation.financial_transactions.count} transactions, #{simulation.gym_states.count} days."
  end
end
