namespace :simulation do
  desc 'Generate visits, transactions, and gym state history'
  task generate: :environment do
    required = ENV.slice('DAYS')
    if required.empty?
      puts <<~USAGE
        Usage: bin/rails simulation:generate DAYS=30 [START_DATE=2026-01-01] [BALANCE=0]
               [VISIT_FEE=500] [SHOE_FEE=200]
               [RENT=300000] [ELECTRICITY=30000] [WATER=10000]
               [OTHER_BILLS=15000] [SALARIES=200000]

        Arguments:
          DAYS        Number of days to simulate (required)
          START_DATE  First day of simulation, YYYY-MM-DD (default: today)
          BALANCE     Initial gym balance (default: 0)
          VISIT_FEE   Fee per visit (default: 500)
          SHOE_FEE    Shoe rental fee per visit (default: 200)
          RENT        Monthly rent (default: 300000)
          ELECTRICITY Monthly electricity bill (default: 30000)
          WATER       Monthly water bill (default: 10000)
          OTHER_BILLS Monthly other bills (default: 15000)
          SALARIES    Monthly staff salaries (default: 200000)

        Requires climbers to be generated first (bin/rails climbers:generate).

        Example:
          bin/rails simulation:generate DAYS=90 START_DATE=2026-01-01 BALANCE=500000 VISIT_FEE=600
      USAGE
      exit
    end

    if VisitorProfile.count.zero?
      puts "No climbers found. Run bin/rails climbers:generate first."
      exit 1
    end

    params = { days: ENV['DAYS'].to_i }
    params[:start_date] = Date.parse(ENV['START_DATE']) if ENV['START_DATE']
    params[:initial_balance] = ENV['BALANCE'].to_f if ENV['BALANCE']
    params[:visit_fee] = ENV['VISIT_FEE'].to_f if ENV['VISIT_FEE']
    params[:shoe_rental_fee] = ENV['SHOE_FEE'].to_f if ENV['SHOE_FEE']
    params[:rent] = ENV['RENT'].to_f if ENV['RENT']
    params[:electricity] = ENV['ELECTRICITY'].to_f if ENV['ELECTRICITY']
    params[:water] = ENV['WATER'].to_f if ENV['WATER']
    params[:other_bills] = ENV['OTHER_BILLS'].to_f if ENV['OTHER_BILLS']
    params[:staff_salaries] = ENV['SALARIES'].to_f if ENV['SALARIES']

    puts "Simulating #{params[:days]} days with #{VisitorProfile.count} climbers..."
    SimulationGenerator.new(**params).call
    puts "Done. Created #{Visit.count} visits, #{FinancialTransaction.count} transactions, #{GymState.count} state snapshots."
  end
end
