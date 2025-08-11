class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :progress_report, :toggle_membership]
  before_action :ensure_owns_resource_or_admin!, only: [:edit, :update]
  before_action :ensure_admin!, only: [:destroy, :toggle_membership]

  def index
    @users = User.includes(:student_progresses, :bookings, :private_lessons_as_student)
    
    # Apply filters
    if filter_params[:role].present?
      @users = @users.where(role: filter_params[:role])
    end
    
    if filter_params[:search].present?
      search_term = "%#{filter_params[:search]}%"
      @users = @users.where(
        "first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?", 
        search_term, search_term, search_term
      )
    end
    
    @users = @users.order(:last_name, :first_name)
                   .page(filter_params[:page])
                   .per(20)
    
    @stats = UserStatsService.new.call
  end

  def show
    @user_dashboard = UserDashboardService.new(@user, current_user).call
  end

  def new
    @user = User.new
    ensure_admin!
  end

  def create
    @user = User.new(user_params)
    
    if UserRegistrationService.new(@user, current_user).call
      redirect_to @user, notice: "Welcome #{@user.full_name}! Account created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # View rendered with @user from before_action
  end

  def update
    if UserUpdateService.new(@user, user_params, current_user).call
      redirect_to @user, notice: 'Profile updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if UserDeletionService.new(@user, current_user).call
      redirect_to users_path, notice: 'User account has been deleted.'
    else
      redirect_to @user, alert: 'Unable to delete user account.'
    end
  end

  def progress_report
    ensure_can_access_student!(@user)
    @progress_data = StudentProgressReportService.new(@user).call
  end

  def toggle_membership
    result = MembershipToggleService.new(@user).call
    redirect_to @user, notice: result[:message]
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :phone, :role, 
      :membership_type, :membership_discount, :waiver_signed
    )
  end

  def filter_params
    params.permit(:role, :membership_type, :search, :page)
  end
end
