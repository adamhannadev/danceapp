class StudentProgressIndexService
  def initialize(user, filter_params)
    @user = user
    @filter_params = filter_params
  end

  def call
    {
      viewing_user: @user,
      student_progresses_paginated: paginated_progresses,
      progresses_by_style: group_by_style,
      available_dance_styles: available_dance_styles,
      selected_style: selected_style,
      selected_level: selected_level,
      stats: progress_stats
    }
  end

  private

  def base_progresses
    @user.student_progresses
         .includes(:figure, :instructor)
         .joins(figure: [:dance_style, :dance_level])
         .order('dance_styles.name, dance_levels.level_number, figures.figure_number')
  end

  def filtered_progresses
    progresses = base_progresses
    
    if selected_style
      progresses = progresses.where(figures: { dance_style_id: selected_style.id })
    end
    
    if selected_level
      progresses = progresses.where(figures: { dance_level_id: selected_level.id })
    end
    
    progresses
  end

  def paginated_progresses
    filtered_progresses.page(@filter_params[:page]).per(20)
  end

  def group_by_style
    paginated_progresses.group_by { |sp| sp.figure.dance_style }
  end

  def available_dance_styles
    DanceStyle.joins(:figures)
              .joins("JOIN student_progresses sp ON sp.figure_id = figures.id")
              .where("sp.user_id = ?", @user.id)
              .distinct
              .order(:name)
  end

  def selected_style
    @filter_params[:dance_style_id].present? ? DanceStyle.find(@filter_params[:dance_style_id]) : nil
  end

  def selected_level
    @filter_params[:dance_level_id].present? ? DanceLevel.find(@filter_params[:dance_level_id]) : nil
  end

  def progress_stats
    progresses = filtered_progresses
    total = progresses.count
    completed = progresses.where('completed_at IS NOT NULL').count
    
    {
      total_figures: total,
      completed_figures: completed,
      overall_completion: total > 0 ? (completed.to_f / total * 100).round(1) : 0
    }
  end
end
