class DashboardController < ApplicationController
  def index
    @dashboard_data = DashboardDataService.new(current_user).call
  end
end
