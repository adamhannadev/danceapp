class StudentProgress < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :figure
  belongs_to :instructor, class_name: 'User'

  # Validations
  validates :user_id, uniqueness: { scope: :figure_id }

  # Scopes
  scope :completed, -> { where.not(completed_at: nil) }
  scope :in_progress, -> { where(completed_at: nil) }
  scope :movement_passed, -> { where(movement_passed: true) }
  scope :timing_passed, -> { where(timing_passed: true) }
  scope :partnering_passed, -> { where(partnering_passed: true) }

  # Instance methods
  def completed?
    movement_passed? && timing_passed? && partnering_passed?
  end

  def completion_percentage
    passed_count = [movement_passed, timing_passed, partnering_passed].count(true)
    (passed_count / 3.0 * 100).round
  end

  def mark_completed!
    if completed?
      update!(completed_at: Time.current)
    end
  end

  def reset_progress!
    update!(
      movement_passed: false,
      timing_passed: false,
      partnering_passed: false,
      completed_at: nil
    )
  end

  def progress_summary
    {
      movement: movement_passed,
      timing: timing_passed,
      partnering: partnering_passed,
      completed: completed?
    }
  end
end
