class InstructorAvailabilitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_instructor, only: [:index, :create]
  before_action :set_availability, only: [:update, :destroy]

  # GET /users/:user_id/availabilities
  def index
    @availabilities = @instructor.instructor_availabilities
    respond_to do |format|
      format.html # renders calendar view
      format.json { render json: @availabilities }
    end
  end

  # POST /instructors/:instructor_id/availabilities
  def create
    @availability = @instructor.instructor_availabilities.new(availability_params)
    if @availability.save
      render json: @availability, status: :created
    else
      render json: @availability.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /instructors/:instructor_id/availabilities/:id
  def update
    if @availability.update(availability_params)
      render json: @availability
    else
      render json: @availability.errors, status: :unprocessable_entity
    end
  end

  # DELETE /instructors/:instructor_id/availabilities/:id
  def destroy
    @availability.destroy
    head :no_content
  end

  private
    def set_instructor
      @instructor = User.find(params[:user_id])
    end

    def set_availability
      @availability = InstructorAvailability.find(params[:id])
    end

    def availability_params
      params.require(:instructor_availability).permit(:start_time, :end_time, :location_id)
    end
end
