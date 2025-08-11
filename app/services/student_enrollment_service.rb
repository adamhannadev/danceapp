class StudentEnrollmentService
  def initialize(student, params, current_user)
    @student = student
    @params = params
    @current_user = current_user
  end

  def call
    return validation_error unless valid_params?
    
    dance_style = DanceStyle.find(@params[:dance_style_id])
    dance_level = DanceLevel.find(@params[:dance_level_id])
    figures = Figure.where(dance_style: dance_style, dance_level: dance_level)
    
    return no_figures_error(dance_style, dance_level) if figures.empty?
    
    created_count = create_progress_records(figures, dance_style, dance_level)
    
    if created_count > 0
      success_response(dance_style, dance_level, created_count)
    else
      already_enrolled_response(dance_style, dance_level)
    end
  end

  private

  def valid_params?
    @params[:dance_style_id].present? && @params[:dance_level_id].present?
  end

  def validation_error
    {
      success: false,
      message: 'Please select both a dance style and level.'
    }
  end

  def no_figures_error(dance_style, dance_level)
    {
      success: false,
      message: "No figures found for #{dance_style.name} #{dance_level.name}"
    }
  end

  def create_progress_records(figures, dance_style, dance_level)
    created_count = 0
    
    figures.each do |figure|
      next if @student.student_progresses.exists?(figure: figure)
      
      @student.student_progresses.create!(
        figure: figure,
        instructor: @current_user,
        movement_passed: false,
        timing_passed: false,
        partnering_passed: false,
        notes: "Enrolled in #{dance_style.name} #{dance_level.name}"
      )
      created_count += 1
    end
    
    created_count
  end

  def success_response(dance_style, dance_level, created_count)
    {
      success: true,
      message: "Successfully enrolled #{@student.full_name} in #{dance_style.name} #{dance_level.name}. Added #{created_count} figures to their progress."
    }
  end

  def already_enrolled_response(dance_style, dance_level)
    {
      success: true,
      message: "#{@student.full_name} is already enrolled in all figures for #{dance_style.name} #{dance_level.name}"
    }
  end
end
