class PrivateLesson < ApplicationRecord
  belongs_to :student, class_name: 'User'
  belongs_to :instructor, class_name: 'User'
  # Removed dance_style and dance_level associations
  belongs_to :location

  # Validations
  validates :scheduled_at, presence: true
  validates :duration, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 180 }
  validates :status, presence: true, inclusion: { in: ['requested', 'scheduled', 'completed', 'cancelled'] }
  validates :cost, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :instructor_must_be_instructor
  validate :student_must_be_student
  validate :scheduled_at_must_be_future, on: :create
  validate :instructor_availability, if: :scheduled_at_changed?
  # Removed dance_style_id and dance_level_id validations

  # Scopes
  scope :upcoming, -> { where(status: ['requested', 'scheduled']).where('scheduled_at > ?', Time.current) }
  scope :completed, -> { where(status: 'completed') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :for_instructor, ->(instructor) { where(instructor: instructor) }
  scope :for_student, ->(student) { where(student: student) }
  scope :on_date, ->(date) { where(scheduled_at: date.beginning_of_day..date.end_of_day) }
  scope :this_week, -> { where(scheduled_at: Time.current.beginning_of_week..Time.current.end_of_week) }
  scope :this_month, -> { where(scheduled_at: Time.current.beginning_of_month..Time.current.end_of_month) }

  # Instance methods
  def can_be_cancelled?
    return false if status == 'completed' || status == 'cancelled'
    scheduled_at > 24.hours.from_now
  end

  def can_be_confirmed?
    status == 'requested'
  end

  def formatted_duration
    hours = duration / 60
    minutes = duration % 60
    return "#{hours}h" if minutes == 0
    return "#{minutes}m" if hours == 0
    "#{hours}h #{minutes}m"
  end

  def end_time
    scheduled_at + duration.minutes
  end

  def status_color
    case status
    when 'requested' then 'warning'
    when 'scheduled' then 'primary'
    when 'completed' then 'success'
    when 'cancelled' then 'danger'
    else 'secondary'
    end
  end

  def status_text
    status.humanize
  end

  private

  def instructor_must_be_instructor
    return unless instructor
    errors.add(:instructor, 'must be an instructor') unless instructor.instructor?
  end

  def student_must_be_student
    return unless student
    errors.add(:student, 'must be a student') unless student.student?
  end

  def scheduled_at_must_be_future
    return unless scheduled_at
    errors.add(:scheduled_at, 'must be in the future') if scheduled_at <= Time.current
  end

  def instructor_availability
    return unless instructor && scheduled_at && duration
    
    # Check if instructor has any conflicting lessons or classes
    lesson_start = scheduled_at
    lesson_end = scheduled_at + duration.minutes
    
    conflicting_lessons = PrivateLesson.where(instructor: instructor)
                                     .where.not(id: id)
                                     .where(status: ['scheduled', 'requested'])
    
    conflicting_lessons.each do |other_lesson|
      other_start = other_lesson.scheduled_at
      other_end = other_lesson.scheduled_at + other_lesson.duration.minutes
      
      # Check for time overlap
      if (lesson_start < other_end) && (lesson_end > other_start)
        errors.add(:scheduled_at, 'conflicts with another lesson for this instructor')
        break
      end
    end
  end
end
