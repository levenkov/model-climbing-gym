class SimulationRunJob < ApplicationJob
  def perform(simulation_id)
    simulation = Simulation.find(simulation_id)
    params = simulation.simulation_params.symbolize_keys
    total = params[:days].to_i

    simulation.update!(status: :simulating, progress_current: 0, progress_total: total)

    SimulationGenerator.new(simulation: simulation, **params).call do |completed|
      simulation.update_columns(progress_current: completed)
    end

    simulation.update!(status: :completed, progress_current: total)
  rescue => e
    simulation&.update(status: :failed) if simulation
    raise
  end
end
