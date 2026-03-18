class ClimberGenerationJob < ApplicationJob
  def perform(simulation_id)
    simulation = Simulation.find(simulation_id)
    params = simulation.climber_params.symbolize_keys
    total = params[:count].to_i

    simulation.update!(status: :generating_climbers, progress_current: 0, progress_total: total)

    ClimberGenerator.new(simulation: simulation, **params).call do |completed|
      simulation.update_columns(progress_current: completed)
    end

    simulation.update!(status: :climbers_ready, progress_current: total)
  rescue => e
    simulation&.update(status: :failed) if simulation
    raise
  end
end
