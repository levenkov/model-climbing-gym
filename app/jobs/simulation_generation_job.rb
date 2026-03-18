class SimulationGenerationJob < ApplicationJob
  def perform(params)
    generator = SimulationGenerator.new(**params.symbolize_keys)
    total = params['days'] || params[:days]

    update_progress(0, total, 'running')

    generator.call do |completed|
      update_progress(completed, total, 'running')
    end

    update_progress(total, total, 'completed')
  end

  private

  def update_progress(completed, total, status)
    Rails.cache.write('simulation_generation_progress', {
      completed: completed,
      total: total,
      status: status
    }, expires_in: 1.hour)
  end
end
