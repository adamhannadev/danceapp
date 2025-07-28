class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :progress_report, :toggle_membership]
  before_action :check_authorization, only: [:edit, :update, :destroy]
  before_action :check_admin_authorization, only: [:toggle_membership]

  def index
    @users = User.all.includes(:student_progresses, :bookings, :private_lessons_as_student)
    
    # Filter by role if specified
    @users = @users.where(role: params[:role]) if params[:role].present?
    
    # Search functionality
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @users = @users.where(
        "first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?", 
        search_term, search_term, search_term
      )
    end
    
    @users = @users.order(:last_name, :first_name)
    
    # Statistics for admin view
    @total_users = User.count
    @students_count = User.students.count
    @instructors_count = User.instructors.count
    @admins_count = User.admins.count
    @members_count = User.with_membership.count
  end

  def show
    @recent_progress = @user.student_progresses.includes(:figure)
                           .order(updated_at: :desc).limit(5) if @user.student?
    @upcoming_bookings = @user.bookings.includes(:class_schedule)
                             .joins(:class_schedule).where('class_schedules.start_datetime > ?', Time.current)
                             .order('class_schedules.start_datetime').limit(5) if @user.student?
    @teaching_classes = @user.dance_classes.includes(:dance_style, :dance_level).limit(5) if @user.instructor?
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      flash[:success] = "Welcome #{@user.full_name}! Your account has been created successfully."
      redirect_to @user
    else
      flash.now[:error] = "There were errors creating your account."
      render :new
    end
  end

  def edit
    # Additional authorization logic would go here
  end

  def update
    if @user.update(user_params)
      flash[:success] = "Profile updated successfully!"
      redirect_to @user
    else
      flash.now[:error] = "There were errors updating your profile."
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = "User account has been deleted."
      redirect_to users_path
    else
      flash[:error] = "Unable to delete user account."
      redirect_to @user
    end
  end

  def progress_report
    # Generate a detailed progress report for the user
    unless current_user.admin? || current_user.instructor? || current_user == @user
      flash[:error] = "You are not authorized to view this progress report."
      redirect_to root_path
      return
    end

    @progress_data = @user.student_progresses.includes(figure: [:dance_style, :dance_level])
                          .joins(figure: [:dance_style, :dance_level])
                          .order('dance_styles.name, dance_levels.level_number, figures.figure_number')
    
    @progress_by_style = @progress_data.group_by { |sp| sp.figure.dance_style }
    
    @overall_stats = {
      total_figures: @progress_data.count,
      completed_figures: @progress_data.completed.count,
      in_progress: @progress_data.where.not(movement_passed: false, timing_passed: false, partnering_passed: false)
                                .where(completed_at: nil).count
    }
    
    @overall_stats[:completion_percentage] = @overall_stats[:total_figures] > 0 ? 
      (@overall_stats[:completed_figures].to_f / @overall_stats[:total_figures] * 100).round(1) : 0
  end

  def toggle_membership
    current_membership = @user.membership_type
    
    case current_membership
    when 'none'
      @user.update!(membership_type: 'monthly', membership_discount: 5.0)
      flash[:success] = "#{@user.full_name} now has a monthly membership with 5% discount."
    when 'monthly'
      @user.update!(membership_type: 'unlimited', membership_discount: 15.0)
      flash[:success] = "#{@user.full_name} upgraded to unlimited membership with 15% discount."
    when 'unlimited'
      @user.update!(membership_type: 'none', membership_discount: 0)
      flash[:success] = "#{@user.full_name}'s membership has been cancelled."
    else
      @user.update!(membership_type: 'monthly', membership_discount: 5.0)
      flash[:success] = "#{@user.full_name} now has a monthly membership."
    end
    
    redirect_to @user
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def check_authorization
    unless current_user.admin? || current_user == @user
      flash[:error] = "You are not authorized to perform this action."
      redirect_to root_path
    end
  end

  def check_admin_authorization
    unless current_user.admin?
      flash[:error] = "You are not authorized to perform this action."
      redirect_to root_path
    end
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email,
      :phone, :role, :membership_type, :membership_discount, :waiver_signed
    )
  end
end
