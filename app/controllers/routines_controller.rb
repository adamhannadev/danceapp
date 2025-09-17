class RoutinesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_routine, only: [:show, :edit, :update, :destroy]
  before_action :authorize_create_update, only: [:new, :create, :edit, :update, :destroy]

  def index
    @routines = Routine.includes(:user, :created_by, :dance_category, :dance_style)
                      .order(created_at: :desc)
    
    # Filter by current user if they're a student (not instructor or admin)
    if current_user.student? && !current_user.instructor? && !current_user.admin?
      @routines = @routines.where(user: current_user)
    end
  end

  def show
    # Students can only view their own routines unless they're also instructors/admins
    if current_user.student? && !current_user.instructor? && !current_user.admin?
      redirect_to routines_path, alert: 'Access denied.' unless @routine.user == current_user
    end
  end

  def new
    @routine = Routine.new
    set_form_data
  end

  def create
    @routine = Routine.new(routine_params)
    @routine.created_by = current_user
    
    if @routine.save
      redirect_to @routine, notice: 'Routine was successfully created.'
    else
      set_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    set_form_data
  end

  def update
    if @routine.update(routine_params)
      redirect_to @routine, notice: 'Routine was successfully updated.'
    else
      set_form_data
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @routine.destroy!
    redirect_to routines_path, notice: 'Routine was successfully deleted.'
  end

  private

  def set_routine
    @routine = Routine.find(params[:id])
  end

  def routine_params
    params.require(:routine).permit(:user_id, :dance_category_id, :dance_style_id, :description)
  end

  def authorize_create_update
    unless current_user.instructor? || current_user.admin?
      redirect_to routines_path, alert: 'Only instructors and administrators can create or modify routines.'
    end
  end

  def set_form_data
    @dance_categories = DanceCategory.order(:name)
    @dance_styles = DanceStyle.order(:name)
    @students = User.where(role: 'student').order(:first_name, :last_name)
  end
end
