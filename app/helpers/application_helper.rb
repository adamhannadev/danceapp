module ApplicationHelper
  def time_duration_in_words(start_time, end_time)
    return "" unless start_time && end_time
    
    duration_minutes = ((end_time - start_time) / 1.minute).round
    hours = duration_minutes / 60
    minutes = duration_minutes % 60
    
    if hours > 0 && minutes > 0
      "#{hours}h #{minutes}m"
    elsif hours > 0
      "#{hours}h"
    else
      "#{minutes}m"
    end
  end

  def dance_level_badge_class(level_name)
    case level_name.downcase
    when /bronze/
      "bronze"
    when /silver/
      "silver"
    when /gold/
      "gold"
    else
      ""
    end
  end

  def dance_style_category_class(category)
    case category.downcase
    when "american smooth"
      "american_smooth"
    when "american rhythm"
      "american_rhythm"
    when "social"
      "social"
    else
      category.downcase.gsub(' ', '_')
    end
  end

  def flash_icon(type)
    case type.to_s
    when 'notice', 'success'
      'fas fa-check-circle'
    when 'alert', 'error', 'danger'
      'fas fa-exclamation-triangle'
    when 'warning'
      'fas fa-exclamation-circle'
    else
      'fas fa-info-circle'
    end
  end

  def flash_class(type)
    case type.to_s
    when 'notice'
      'info'
    when 'alert'
      'warning'
    when 'error'
      'danger'
    when 'success'
      'success'
    else
      'info'
    end
  end

  def page_title(title = nil)
    if title
      content_for(:title, title)
    end
    content_for?(:title) ? content_for(:title) : "Ballroom Dancing CRM"
  end

  def user_role_color(role)
    case role.to_s
    when 'admin'
      'danger'
    when 'instructor'
      'warning'
    when 'student'
      'primary'
    else
      'secondary'
    end
  end

  def user_role_icon(role)
    case role.to_s
    when 'admin'
      'crown'
    when 'instructor'
      'chalkboard-teacher'
    when 'student'
      'graduation-cap'
    else
      'user'
    end
  end

  def user_role_display(role)
    case role.to_s
    when 'admin'
      'Administrator'
    when 'instructor'
      'Instructor'
    when 'student'
      'Student'
    else
      role.to_s.humanize
    end
  end

  def membership_badge_class(membership_type)
    case membership_type.to_s
    when 'annual'
      'success'
    when 'monthly'
      'info'
    when 'none'
      'secondary'
    else
      'secondary'
    end
  end

  def membership_display(membership_type)
    case membership_type.to_s
    when 'annual'
      'Annual Member'
    when 'monthly'
      'Monthly Member'
    when 'none'
      'Drop-in'
    else
      'No Membership'
    end
  end

  # Waiver helper methods
  def current_user_needs_waiver?
    return false unless current_user
    !current_user.waiver_signed?
  end

  def waiver_modal_trigger(text: "Sign Waiver", css_class: "btn btn-warning")
    return "" unless current_user_needs_waiver?
    
    button_tag(text, 
      type: "button",
      class: css_class,
      data: { 
        bs_toggle: "modal", 
        bs_target: "#waiverModal" 
      }
    )
  end
end
