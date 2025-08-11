class DanceClassesController < ApplicationController
  before_action :set_dance_class, only: [:show, :edit, :update, :destroy]
  before_action :ensure_instructor_or_admin!, except: [:index, :show]

  def index
    @classes_data = DanceClassIndexService.new(filter_params).call
  end

  def show
    @class_details = DanceClassDetailService.new(@dance_class, current_user).call
  end

  def new
    @dance_class = DanceClass.new
    @form_data = DanceClassFormService.new.call
  end

  def create
    @dance_class = DanceClass.new(dance_class_params)
    @dance_class.instructor = current_user if current_user.instructor?
    
    if DanceClassCreationService.new(@dance_class, current_user).call
      redirect_to @dance_class, notice: 'Dance class was successfully created.'
    else
      @form_data = DanceClassFormService.new.call
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @form_data = DanceClassFormService.new.call
  end

  def update
    if DanceClassUpdateService.new(@dance_class, dance_class_params, current_user).call
      redirect_to @dance_class, notice: 'Dance class was successfully updated.'
    else
      @form_data = DanceClassFormService.new.call
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if DanceClassDeletionService.new(@dance_class, current_user).call
      redirect_to dance_classes_url, notice: 'Dance class was successfully deleted.'
    else
      redirect_to @dance_class, alert: 'Unable to delete dance class.'
    end
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

  def filter_params
    params.permit(:dance_style_id, :instructor_id, :page)
  end
end
