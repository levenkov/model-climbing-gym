module Model
  class GeneratorController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:progress]
    skip_after_action :verify_authorized, raise: false

    def index
      @climber_count = VisitorProfile.count
      @simulation_days = GymState.count
    end

    def generate_climbers
      params_hash = {
        count: gen_params[:count].to_i,
        visits_per_week_mean: gen_params[:visits_per_week_mean].to_f,
        visits_per_week_std: gen_params[:visits_per_week_std].to_f,
        flexible_schedule_ratio: gen_params[:flexible_schedule_ratio].to_f,
        own_shoes_ratio: gen_params[:own_shoes_ratio].to_f
      }

      Rails.cache.write('climber_generation_progress', { completed: 0, total: params_hash[:count], status: 'running' })
      ClimberGenerationJob.perform_later(params_hash)

      render json: { status: 'started' }
    end

    def generate_simulation
      params_hash = {
        days: sim_params[:days].to_i,
        start_date: Date.parse(sim_params[:start_date]),
        initial_balance: sim_params[:initial_balance].to_f,
        visit_fee: sim_params[:visit_fee].to_f,
        shoe_rental_fee: sim_params[:shoe_rental_fee].to_f,
        rent: sim_params[:rent].to_f,
        electricity: sim_params[:electricity].to_f,
        water: sim_params[:water].to_f,
        other_bills: sim_params[:other_bills].to_f,
        staff_salaries: sim_params[:staff_salaries].to_f
      }

      Rails.cache.write('simulation_generation_progress', { completed: 0, total: params_hash[:days], status: 'running' })
      SimulationGenerationJob.perform_later(params_hash)

      render json: { status: 'started' }
    end

    def progress
      key = params[:job] == 'simulation' ? 'simulation_generation_progress' : 'climber_generation_progress'
      data = Rails.cache.read(key) || { completed: 0, total: 0, status: 'idle' }
      render json: data
    end

    def reset
      Visit.delete_all
      FinancialTransaction.delete_all
      GymState.delete_all
      VisitorProfile.delete_all
      User.where.not(id: User::ROOT_USER_ID).delete_all

      Rails.cache.delete('climber_generation_progress')
      Rails.cache.delete('simulation_generation_progress')

      redirect_to model_generator_index_path, notice: 'All generated data has been reset.'
    end

    private

    def gen_params
      params.require(:climber).permit(:count, :visits_per_week_mean, :visits_per_week_std, :flexible_schedule_ratio, :own_shoes_ratio)
    end

    def sim_params
      params.require(:simulation).permit(:days, :start_date, :initial_balance, :visit_fee, :shoe_rental_fee,
                                         :rent, :electricity, :water, :other_bills, :staff_salaries)
    end
  end
end
