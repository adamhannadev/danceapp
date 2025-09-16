class RecurringLessonService
  def initialize(parent_lesson)
    @parent_lesson = parent_lesson
  end

  def create_recurring_lessons
    return [] unless @parent_lesson.is_recurring?

    lessons_created = []
    current_date = next_occurrence_date(@parent_lesson.scheduled_at)

    while current_date <= end_date_limit
      # Create the recurring lesson instance
      recurring_lesson = create_lesson_instance(current_date)
      
      if recurring_lesson.save
        lessons_created << recurring_lesson
      else
        Rails.logger.error "Failed to create recurring lesson: #{recurring_lesson.errors.full_messages}"
      end

      current_date = next_occurrence_date(current_date)
    end

    lessons_created
  end

  def delete_future_lessons(from_date = nil)
    return 0 unless @parent_lesson.is_parent_lesson?

    if from_date
      # Delete lessons scheduled at or after the specified date
      future_lessons = @parent_lesson.recurring_lessons.where('scheduled_at >= ?', from_date)
    else
      # Delete all future lessons (current behavior)
      future_lessons = @parent_lesson.future_recurring_lessons
    end
    
    count = future_lessons.count
    future_lessons.destroy_all
    count
  end

  def update_recurring_series(params)
    # If recurring is being turned off, delete future lessons
    if params[:is_recurring] == '0' || params[:is_recurring] == false
      deleted_count = delete_future_lessons
      @parent_lesson.update(is_recurring: false, recurrence_rule: nil, recurring_until: nil)
      return { deleted_count: deleted_count }
    end

    # If recurrence rule changed, recreate the series
    if params[:recurrence_rule] != @parent_lesson.recurrence_rule || 
       params[:recurring_until] != @parent_lesson.recurring_until&.to_s
      
      delete_future_lessons
      @parent_lesson.update(
        recurrence_rule: params[:recurrence_rule],
        recurring_until: params[:recurring_until]
      )
      lessons_created = create_recurring_lessons
      return { created_count: lessons_created.length, lessons: lessons_created }
    end

    { message: 'No changes to recurring series' }
  end

  private

  def create_lesson_instance(scheduled_time)
    @parent_lesson.recurring_lessons.build(
      student: @parent_lesson.student,
      instructor: @parent_lesson.instructor,
      location: @parent_lesson.location,
      scheduled_at: scheduled_time,
      duration: @parent_lesson.duration,
      cost: @parent_lesson.cost,
      status: @parent_lesson.status,
      notes: @parent_lesson.notes,
      is_recurring: false
    )
  end

  def next_occurrence_date(current_date)
    case @parent_lesson.recurrence_rule.downcase
    when 'weekly'
      current_date + 1.week
    when 'biweekly'
      current_date + 2.weeks
    when 'monthly'
      current_date + 1.month
    when 'daily'
      current_date + 1.day
    else
      current_date + 1.week # Default to weekly
    end
  end

  def end_date_limit
    # Use the specified end date or end of current year, whichever is earlier
    specified_end = @parent_lesson.recurring_until&.end_of_day || Date.current.end_of_year
    end_of_year = Date.current.end_of_year.end_of_day
    
    [specified_end, end_of_year].min
  end
end