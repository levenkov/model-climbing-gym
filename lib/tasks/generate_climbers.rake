namespace :climbers do
  desc 'Generate climbers with visitor profiles'
  task generate: :environment do
    if ENV.slice('COUNT', 'MEAN', 'STD', 'FLEXIBLE', 'SHOES').empty?
      puts <<~USAGE
        Usage: bin/rails climbers:generate COUNT=100 [MEAN=3.0] [STD=1.5] [FLEXIBLE=0.4] [SHOES=0.3]

        Arguments:
          COUNT     Number of climbers to generate (required)
          MEAN      Mean visits per week, normal distribution (default: 3.0)
          STD       Standard deviation for visits per week (default: 1.5)
          FLEXIBLE  Ratio of climbers with flexible work schedule, 0.0-1.0 (default: 0.4)
          SHOES     Ratio of climbers who own climbing shoes, 0.0-1.0 (default: 0.3)

        Example:
          bin/rails climbers:generate COUNT=50 MEAN=4.0 STD=1.0 FLEXIBLE=0.6 SHOES=0.5
      USAGE
      exit
    end

    params = {
      count: ENV['COUNT'].to_i,
      visits_per_week_mean: (ENV['MEAN'] || 3.0).to_f,
      visits_per_week_std: (ENV['STD'] || 1.5).to_f,
      flexible_schedule_ratio: (ENV['FLEXIBLE'] || 0.4).to_f,
      own_shoes_ratio: (ENV['SHOES'] || 0.3).to_f
    }

    puts "Generating #{params[:count]} climbers..."
    users = ClimberGenerator.new(**params).call
    puts
    puts "Generated #{users.size} climbers with visitor profiles."
  end
end
