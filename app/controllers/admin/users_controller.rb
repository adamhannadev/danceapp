class Admin::UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :ensure_instructor_or_admin!

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

  def new
    @user = User.new
  end

  def create
    # Store current session info before creating new user
    current_admin = current_user
    
    # Create new user instance
    @user = User.new(user_params)
    
    # Handle waiver signature from modal during registration
    if params[:user][:waiver_signed_at].present?
      @user.waiver_signed = true
      @user.waiver_signed_at = params[:user][:waiver_signed_at]
    end
    
    # Save the user directly without triggering Devise session callbacks
    begin
      ActiveRecord::Base.transaction do
        @user.save!
        
        # Set up default progress if student
        if @user.student?
          setup_student_defaults(@user, current_admin)
        end
      end
      
      redirect_to admin_users_path, notice: "User account for #{@user.full_name} created successfully."
    rescue ActiveRecord::RecordInvalid
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user_dashboard = UserDashboardService.new(@user, current_user).call
    @recent_progress = @user_dashboard[:recent_progress] || []
    @upcoming_bookings = @user_dashboard[:upcoming_bookings] || []
    @teaching_classes = @user_dashboard[:teaching_classes] || []
    @enrollment_stats = @user_dashboard[:enrollment_stats] || {}
    @instructor_availabilities = @user_dashboard[:instructor_availabilities] || []
    @upcoming_availabilities = @user_dashboard[:upcoming_availabilities] || []
    
    # Load routines for students (visible to admins/instructors viewing any student, or students viewing themselves)
    if @user.student? && (current_user.admin? || current_user.instructor? || current_user == @user)
      @student_routines = @user.routines.includes(:created_by, :dance_category, :dance_style)
                               .order(created_at: :desc).limit(3)
    end
  end

  def edit
    ensure_owns_resource_or_admin!(@user)
  end

  def update
    ensure_owns_resource_or_admin!(@user)
    
    if UserUpdateService.new(@user, user_params, current_user).call
      redirect_to admin_user_path(@user), notice: 'Profile updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    ensure_admin!
    
    if UserDeletionService.new(@user, current_user).call
      redirect_to admin_users_path, notice: 'User account has been deleted.'
    else
      redirect_to admin_user_path(@user), alert: 'Unable to delete user account.'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :phone, :role, 
      :membership_type, :membership_discount, :waiver_signed, :waiver_signed_at, :goals,
      :password, :password_confirmation
    )
  end

  def filter_params
    params.permit(:role, :membership_type, :search, :page)
  end

  def setup_student_defaults(user, instructor)
    # Create default progress records for beginner level figures
    beginner_level = DanceLevel.find_by(name: 'Beginner') || DanceLevel.order(:level_number).first
    return unless beginner_level
    
    beginner_figures = Figure.where(dance_level: beginner_level, is_core: true)
    
    beginner_figures.find_each do |figure|
      user.student_progresses.create!(
        figure: figure,
        instructor: instructor,
        movement_passed: false,
        timing_passed: false,
        partnering_passed: false,
        notes: "Enrolled in #{figure.dance_style.name}"
      )
    end
  end
end