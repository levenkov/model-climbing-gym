module Model
  class BaseController < ApplicationController
    before_action :authenticate_user!
    skip_after_action :verify_authorized, raise: false

    private

    def current_simulation
      @current_simulation ||= current_user.simulations.find(params[:simulation_id])
    end
  end
end
