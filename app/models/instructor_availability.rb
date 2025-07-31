class InstructorAvailability < ApplicationRecord
  belongs_to :instructor, class_name: 'User', foreign_key: 'instructor_id'
  belongs_to :location, optional: true

  validates :start_time, :end_time, presence: true
  validates :end_time, comparison: { greater_than: :start_time }
  
  scope :for_instructor, ->(instructor) { where(instructor: instructor) }
  scope :in_date_range, ->(start_date, end_date) { 
    where(start_time: start_date.beginning_of_day..end_date.end_of_day) 
  }
end
