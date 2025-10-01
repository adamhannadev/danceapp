class StudentEnrollmentService
  def initialize(student, params, current_user)
    @student = student
    @params = params
    @current_user = current_user
  end

  def call
    return validation_error unless valid_params?
    
    dance_styles = DanceStyle.where(id: @params[:dance_style_ids])
    dance_levels = DanceLevel.where(id: @params[:dance_level_ids])
    
    return no_styles_error if dance_styles.empty?
    return no_levels_error if dance_levels.empty?
    
    total_created = 0
    enrollment_results = []
    
    dance_styles.each do |dance_style|
      dance_levels.each do |dance_level|
        figures = Figure.where(dance_style: dance_style, dance_level: dance_level)
        
        if figures.any?
          created_count = create_progress_records(figures, dance_style, dance_level)
          total_created += created_count
          enrollment_results << {
            dance_style: dance_style,
            dance_level: dance_level,
            figures_added: created_count,
            total_figures: figures.count
          }
        end
      end
    end
    
    if total_created > 0
      success_response(dance_styles, dance_levels, enrollment_results, total_created)
    else
      already_enrolled_response(dance_styles, dance_levels)
    end
  end

  private

  def valid_params?
    @params[:dance_style_ids].present? && @params[:dance_style_ids].any? && 
    @params[:dance_level_ids].present? && @params[:dance_level_ids].any?
  end

  def validation_error
    {
      success: false,
      message: 'Please select at least one dance style and at least one dance level.'
    }
  end

  def no_styles_error
    {
      success: false,
      message: 'No valid dance styles selected.'
    }
  end

  def no_levels_error
    {
      success: false,
      message: 'No valid dance levels selected.'
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
        notes: ""
      )
      created_count += 1
    end
    
    created_count
  end

  def success_response(dance_styles, dance_levels, enrollment_results, total_created)
    style_names = dance_styles.map(&:name).join(', ')
    level_names = dance_levels.map(&:name).join(', ')
    
    details = enrollment_results.map do |result|
      "#{result[:dance_style].name} - #{result[:dance_level].name}: #{result[:figures_added]} new figures"
    end.join('; ')
    
    {
      success: true,
      message: "Successfully enrolled #{@student.full_name} in #{dance_styles.count} style(s) (#{style_names}) across #{dance_levels.count} level(s) (#{level_names}). Added #{total_created} total figures. Details: #{details}"
    }
  end

  def already_enrolled_response(dance_styles, dance_levels)
    style_names = dance_styles.map(&:name).join(', ')
    level_names = dance_levels.map(&:name).join(', ')
    {
      success: true,
      message: "#{@student.full_name} is already enrolled in all figures for the selected combinations: #{style_names} at levels: #{level_names}"
    }
  end
end
