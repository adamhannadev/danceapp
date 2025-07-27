class StudentProgressController < ApplicationController
  before_action :set_student_progress, only: [:show, :update, :mark_progress]
  before_action :ensure_current_user

  def index
    @student_progresses = current_user.student_progresses.includes(:figure, :instructor)
                                     .joins(figure: [:dance_style, :dance_level])
                                     .order('dance_styles.name, dance_levels.level_number, figures.figure_number')
    
    # Group by dance style for better organization
    @progresses_by_style = @student_progresses.group_by { |sp| sp.figure.dance_style }
    
    # Calculate overall statistics
    @total_figures = @student_progresses.count
    @completed_figures = @student_progresses.completed.count
    @overall_completion = @total_figures > 0 ? (@completed_figures.to_f / @total_figures * 100).round(1) : 0
    
    # Filter parameters
    @selected_style = params[:dance_style_id].present? ? DanceStyle.find(params[:dance_style_id]) : nil
    @selected_level = params[:dance_level_id].present? ? DanceLevel.find(params[:dance_level_id]) : nil
    
    if @selected_style || @selected_level
      @student_progresses = @student_progresses.joins(figure: [:dance_style, :dance_level])
      @student_progresses = @student_progresses.where(figures: { dance_style_id: @selected_style.id }) if @selected_style
      @student_progresses = @student_progresses.where(figures: { dance_level_id: @selected_level.id }) if @selected_level
      @progresses_by_style = @student_progresses.group_by { |sp| sp.figure.dance_style }
    end
  end

  def show
    @figure = @student_progress.figure
    @dance_style = @figure.dance_style
    @dance_level = @figure.dance_level
    @instructor = @student_progress.instructor
  end

  def update
    if @student_progress.update(student_progress_params)
      # Check if all components are now passed and mark as completed
      if @student_progress.completed? && @student_progress.completed_at.nil?
        @student_progress.mark_completed!
        flash[:success] = "Congratulations! You've completed #{@student_progress.figure.name}!"
      else
        flash[:success] = "Progress updated successfully!"
      end
      
      redirect_to @student_progress
    else
      flash[:error] = "There was an error updating your progress."
      render :show
    end
  end

  def mark_progress
    component = params[:component]
    
    case component
    when 'movement'
      @student_progress.toggle!(:movement_passed)
    when 'timing'
      @student_progress.toggle!(:timing_passed)
    when 'partnering'
      @student_progress.toggle!(:partnering_passed)
    end
    
    # Check if all components are now passed
    if @student_progress.completed? && @student_progress.completed_at.nil?
      @student_progress.mark_completed!
      flash[:success] = "Congratulations! You've completed #{@student_progress.figure.name}!"
    end
    
    respond_to do |format|
      format.html { redirect_to @student_progress }
      format.json { render json: { success: true, completed: @student_progress.completed? } }
    end
  end

  private

  def set_student_progress
    @student_progress = current_user.student_progresses.find(params[:id])
  end

  def student_progress_params
    params.require(:student_progress).permit(:movement_passed, :timing_passed, :partnering_passed, :notes)
  end

  def ensure_current_user
    # Simple current_user simulation - in a real app this would be handled by Devise or similar
    @current_user ||= User.students.first # For demo purposes
  end

  def current_user
    @current_user
  end
  helper_method :current_user
end
