class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :set_current_user, except: [:new, :create]

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
                             .joins(:class_schedule).where('class_schedules.start_time > ?', Time.current)
                             .order('class_schedules.start_time').limit(5) if @user.student?
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

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email,
      :phone, :role, :membership_type, :membership_discount, :waiver_signed
    )
  end
end
