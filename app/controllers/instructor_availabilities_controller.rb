class InstructorAvailabilitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_instructor, only: [:index, :create]
  before_action :set_availability, only: [:update, :destroy]

  # GET /users/:user_id/availabilities
  def index
    @availabilities = @instructor.instructor_availabilities
    respond_to do |format|
      format.html # renders calendar view
      format.json { 
        render json: @availabilities.map { |availability|
          {
            id: availability.id,
            title: availability.location&.name || "Available",
            start: availability.start_time.iso8601,
            end: availability.end_time.iso8601,
            backgroundColor: '#28a745',
            borderColor: '#1e7e34'
          }
        }
      }
    end
  end

  # POST /users/:user_id/availabilities
  def create
    @availability = @instructor.instructor_availabilities.new(availability_params)
    
    # Set default location if none provided and one exists
    if @availability.location_id.blank? && Location.exists?
      @availability.location = Location.first
    end
    
    if @availability.save
      render json: {
        id: @availability.id,
        title: @availability.location&.name || "Available",
        start: @availability.start_time.iso8601,
        end: @availability.end_time.iso8601,
        backgroundColor: '#28a745',
        borderColor: '#1e7e34'
      }, status: :created
    else
      render json: @availability.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/:user_id/availabilities/:id
  def update
    if @availability.update(availability_params)
      render json: {
        id: @availability.id,
        title: @availability.location&.name || "Available",
        start: @availability.start_time.iso8601,
        end: @availability.end_time.iso8601,
        backgroundColor: '#28a745',
        borderColor: '#1e7e34'
      }
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
