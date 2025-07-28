module StudentProgressHelper
  # Helper to generate correct path based on whether viewing nested user progress
  def student_progress_index_path_for(user = nil)
    if user && user != current_user && user_signed_in?
      user_student_progress_index_path(user)
    else
      student_progress_index_path
    end
  end

  def student_progress_path_for(progress, user = nil)
    if user && user != current_user && user_signed_in?
      user_student_progress_path(user, progress)
    else
      student_progress_path(progress)
    end
  end

  def progress_percentage_color(percentage)
    case percentage
    when 0...25
      'danger'
    when 25...50
      'warning'
    when 50...75
      'info'
    when 75...100
      'primary'
    else
      'success'
    end
  end

  def progress_status_badge(student_progress)
    if student_progress.completed?
      content_tag :span, class: "badge bg-success" do
        concat content_tag(:i, "", class: "fas fa-check-circle me-1")
        concat "Completed"
      end
    else
      content_tag :span, class: "badge bg-warning" do
        concat content_tag(:i, "", class: "fas fa-clock me-1")
        concat "In Progress"
      end
    end
  end

  def component_status_icon(passed)
    if passed
      content_tag :i, "", class: "fas fa-check-circle text-success"
    else
      content_tag :i, "", class: "fas fa-circle text-muted"
    end
  end

  def progress_circle_svg(percentage, size = 120)
    radius = (size / 2) - 10
    circumference = 2 * Math::PI * radius
    offset = circumference - (percentage / 100.0) * circumference

    content_tag :svg, width: size, height: size, class: "progress-circle" do
      concat content_tag(:circle, "", 
        cx: size/2, cy: size/2, r: radius,
        stroke: "#e9ecef", stroke_width: "8", fill: "transparent")
      concat content_tag(:circle, "",
        cx: size/2, cy: size/2, r: radius,
        stroke: "#0d6efd", stroke_width: "8", fill: "transparent",
        stroke_dasharray: circumference,
        stroke_dashoffset: offset,
        transform: "rotate(-90 #{size/2} #{size/2})",
        class: "progress-bar-circle")
    end
  end

  def figure_difficulty_badge(figure)
    if figure.core_figure?
      content_tag :span, "Core Figure", class: "badge bg-primary"
    else
      content_tag :span, "Variation", class: "badge bg-secondary"
    end
  end

  def level_progress_summary(progresses)
    total = progresses.count
    completed = progresses.count(&:completed?)
    percentage = total > 0 ? (completed.to_f / total * 100).round(1) : 0
    
    {
      total: total,
      completed: completed,
      remaining: total - completed,
      percentage: percentage
    }
  end

  def format_progress_date(date)
    if date
      if date.today?
        "Today at #{date.strftime('%I:%M %p')}"
      elsif date.to_date == Date.current - 1.day
        "Yesterday at #{date.strftime('%I:%M %p')}"
      elsif date.to_date > Date.current - 7.days
        date.strftime('%A at %I:%M %p')
      else
        date.strftime('%B %d, %Y')
      end
    else
      "Not started"
    end
  end

  def progress_components_summary(student_progress)
    components = {
      movement: student_progress.movement_passed?,
      timing: student_progress.timing_passed?,
      partnering: student_progress.partnering_passed?
    }
    
    passed_count = components.values.count(true)
    total_count = components.size
    
    {
      components: components,
      passed_count: passed_count,
      total_count: total_count,
      percentage: (passed_count.to_f / total_count * 100).round
    }
  end
end
