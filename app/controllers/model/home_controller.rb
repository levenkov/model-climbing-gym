module Model
  class HomeController < BaseController
    def index
      @simulations = current_user.simulations.order(created_at: :desc)
    end
  end
end
