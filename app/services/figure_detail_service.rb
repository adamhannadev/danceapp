class FigureDetailService
  def initialize(figure)
    @figure = figure
  end

  def call
    {
      student_progresses: recent_progress,
      progress_stats: progress_statistics,
      related_figures: related_figures
    }
  end

  private

  def recent_progress
    @figure.student_progresses
           .includes(:user, :instructor)
           .order(updated_at: :desc)
           .limit(10)
  end

  def progress_statistics
    progresses = @figure.student_progresses
    total = progresses.count
    completed = progresses.where('completed_at IS NOT NULL').count
    
    {
      total_students: total,
      completed_count: completed,
      completion_rate: total > 0 ? (completed.to_f / total * 100).round(1) : 0,
      average_completion_time: calculate_average_completion_time(progresses.where('completed_at IS NOT NULL'))
    }
  end

  def related_figures
    Figure.where(dance_style: @figure.dance_style, dance_level: @figure.dance_level)
          .where.not(id: @figure.id)
          .order(:figure_number)
          .limit(5)
  end

  def calculate_average_completion_time(completed_progresses)
    return 0 if completed_progresses.empty?
    
    times = completed_progresses.map do |progress|
      next unless progress.completed_at && progress.created_at
      
      (progress.completed_at - progress.created_at) / 1.day
    end.compact
    
    return 0 if times.empty?
    
    (times.sum / times.length).round(1)
  end
end
