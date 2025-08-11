class AllStudentsProgressService
  def call
    {
      users_with_progress: users_with_progress,
      progress_stats: calculate_progress_stats
    }
  end

  private

  def users_with_progress
    User.students
        .joins(:student_progresses)
        .includes(student_progresses: [{ figure: [:dance_style, :dance_level] }, :instructor])
        .distinct
        .order(:last_name, :first_name)
  end

  def calculate_progress_stats
    stats = {}
    
    users_with_progress.each do |user|
      total = user.student_progresses.count
      completed = user.student_progresses.where('completed_at IS NOT NULL').count
      
      stats[user.id] = {
        total: total,
        completed: completed,
        percentage: total > 0 ? (completed.to_f / total * 100).round(1) : 0
      }
    end
    
    stats
  end
end
