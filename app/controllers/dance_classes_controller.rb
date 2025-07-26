class DanceClassesController < ApplicationController
  before_action :set_dance_class, only: [:show, :edit, :update, :destroy]

  def index
    @dance_classes = DanceClass.includes(:dance_style, :dance_level, :instructor, :location)
                               .order(:name)
    
    # Add pagination if Kaminari is available
    if defined?(Kaminari)
      @dance_classes = @dance_classes.page(params[:page]).per(12)
    else
      @dance_classes = @dance_classes.limit(50) # Fallback limit
    end
    
    # Filter by dance style if provided
    if params[:dance_style_id].present?
      @dance_classes = @dance_classes.where(dance_style_id: params[:dance_style_id])
    end
    
    # Filter by instructor if provided
    if params[:instructor_id].present?
      @dance_classes = @dance_classes.where(instructor_id: params[:instructor_id])
    end
    
    @dance_styles = DanceStyle.all
    @instructors = User.instructors
  end

  def show
    @class_schedules = @dance_class.class_schedules.includes(:bookings)
    @upcoming_schedules = @class_schedules.where('start_datetime > ?', Time.current)
                                         .order(:start_datetime)
                                         .limit(5)
  end

  def new
    @dance_class = DanceClass.new
    @dance_styles = DanceStyle.all
    @dance_levels = DanceLevel.all
    @instructors = User.instructors
    @locations = Location.active
  end

  def create
    @dance_class = DanceClass.new(dance_class_params)
    
    if @dance_class.save
      redirect_to @dance_class, notice: 'Dance class was successfully created.'
    else
      @dance_styles = DanceStyle.all
      @dance_levels = DanceLevel.all
      @instructors = User.instructors
      @locations = Location.active
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @dance_styles = DanceStyle.all
    @dance_levels = DanceLevel.all
    @instructors = User.instructors
    @locations = Location.active
  end

  def update
    if @dance_class.update(dance_class_params)
      redirect_to @dance_class, notice: 'Dance class was successfully updated.'
    else
      @dance_styles = DanceStyle.all
      @dance_levels = DanceLevel.all
      @instructors = User.instructors
      @locations = Location.active
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @dance_class.destroy
    redirect_to dance_classes_url, notice: 'Dance class was successfully deleted.'
  end

  private

  def set_dance_class
    @dance_class = DanceClass.find(params[:id])
  end

  def dance_class_params
    params.require(:dance_class).permit(:name, :dance_style_id, :dance_level_id, 
                                      :instructor_id, :location_id, :duration_minutes, 
                                      :max_capacity, :price, :description, :class_type)
  end
end
