module Model
  class SimulationsController < BaseController
    def index
      @simulations = current_user.simulations.order(created_at: :desc)
    end

    def show
      @simulation = current_user.simulations.find(params[:id])
      @climber_count = @simulation.visitor_profiles.count
      @visit_count = @simulation.visits.count
      @transaction_count = @simulation.financial_transactions.count
      @simulation_days = @simulation.gym_states.count
    end

    def new
      @simulation = current_user.simulations.build
    end

    def create
      @simulation = current_user.simulations.build(
        name: simulation_params[:name],
        climber_params: {
          count: simulation_params[:climber_count].to_i,
          visits_per_week_mean: simulation_params[:visits_per_week_mean].to_f,
          visits_per_week_std: simulation_params[:visits_per_week_std].to_f,
          flexible_schedule_ratio: simulation_params[:flexible_schedule_ratio].to_f,
          own_shoes_ratio: simulation_params[:own_shoes_ratio].to_f
        },
        simulation_params: {
          days: simulation_params[:days].to_i,
          start_date: simulation_params[:start_date],
          initial_balance: simulation_params[:initial_balance].to_f,
          visit_fee: simulation_params[:visit_fee].to_f,
          shoe_rental_fee: simulation_params[:shoe_rental_fee].to_f,
          rent: simulation_params[:rent].to_f,
          electricity: simulation_params[:electricity].to_f,
          water: simulation_params[:water].to_f,
          other_bills: simulation_params[:other_bills].to_f,
          staff_salaries: simulation_params[:staff_salaries].to_f
        }
      )

      if @simulation.save
        redirect_to simulation_path(@simulation)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def generate_climbers
      simulation = current_user.simulations.find(params[:id])
      ClimberGenerationJob.perform_later(simulation.id)
      redirect_to simulation_path(simulation)
    end

    def run_simulation
      simulation = current_user.simulations.find(params[:id])
      SimulationRunJob.perform_later(simulation.id)
      redirect_to simulation_path(simulation)
    end

    def reset_simulation
      simulation = current_user.simulations.find(params[:id])
      simulation.visits.delete_all
      simulation.financial_transactions.delete_all
      simulation.gym_states.delete_all
      simulation.update!(status: :climbers_ready, progress_current: 0, progress_total: 0)
      redirect_to simulation_path(simulation), notice: 'Simulation data reset. Climbers preserved.'
    end

    def progress
      simulation = current_user.simulations.find(params[:id])
      render json: {
        status: simulation.status,
        current: simulation.progress_current,
        total: simulation.progress_total
      }
    end

    def destroy
      simulation = current_user.simulations.find(params[:id])
      simulation.destroy!
      redirect_to root_path, notice: 'Simulation deleted.'
    end

    private

    def simulation_params
      params.require(:simulation).permit(
        :name, :climber_count, :visits_per_week_mean, :visits_per_week_std,
        :flexible_schedule_ratio, :own_shoes_ratio,
        :days, :start_date, :initial_balance, :visit_fee, :shoe_rental_fee,
        :rent, :electricity, :water, :other_bills, :staff_salaries
      )
    end
  end
end
