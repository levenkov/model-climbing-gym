class ClimberGenerationJob < ApplicationJob
  def perform(params)
    generator = ClimberGenerator.new(**params.symbolize_keys)
    total = params['count'] || params[:count]

    update_progress(0, total, 'running')

    generator.call do |completed|
      update_progress(completed, total, 'running')
    end

    update_progress(total, total, 'completed')
  end

  private

  def update_progress(completed, total, status)
    Rails.cache.write('climber_generation_progress', {
      completed: completed,
      total: total,
      status: status
    }, expires_in: 1.hour)
  end
end
