class DashboardController < ApplicationController
  def index
    @dashboard_data = DashboardDataService.new(current_user).call
  end

  def test_alert
    case params[:type]
    when 'error'
      flash[:alert] = "This is an error message that will auto-dismiss in 5 seconds!"
    when 'warning'
      flash[:warning] = "This is a warning message that will auto-dismiss in 5 seconds!"
    when 'info'
      flash[:info] = "This is an info message that will auto-dismiss in 5 seconds!"
    else
      flash[:notice] = "This is a success message that will auto-dismiss in 5 seconds!"
    end
    redirect_to root_path
  end
end
