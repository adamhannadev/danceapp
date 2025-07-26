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

  def page_title(title = nil)
    if title
      content_for(:title, title)
    end
    content_for?(:title) ? content_for(:title) : "Ballroom Dancing CRM"
  end
end
