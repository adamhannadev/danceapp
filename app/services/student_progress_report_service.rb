class StudentProgressReportService
  def initialize(user)
    @user = user
  end

  def call
    {
      progress_data: formatted_progress_data,
      progress_by_style: group_progress_by_style,
      overall_stats: calculate_overall_stats
    }
  end

  private

  def formatted_progress_data
    @user.student_progresses
         .includes(figure: [:dance_style, :dance_level])
         .joins(figure: [:dance_style, :dance_level])
         .order('dance_styles.name, dance_levels.level_number, figures.figure_number')
  end

  def group_progress_by_style
    formatted_progress_data.group_by { |sp| sp.figure.dance_style }
  end

  def calculate_overall_stats
    progress_data = formatted_progress_data
    
    total = progress_data.count
    completed = progress_data.where('completed_at IS NOT NULL').count
    in_progress = progress_data.where.not(
      movement_passed: false, 
      timing_passed: false, 
      partnering_passed: false
    ).where(completed_at: nil).count
    
    {
      total_figures: total,
      completed_figures: completed,
      in_progress: in_progress,
      completion_percentage: total > 0 ? (completed.to_f / total * 100).round(1) : 0
    }
  end
end
