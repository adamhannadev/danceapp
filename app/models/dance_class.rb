class DanceClass < ApplicationRecord
  # Associations
  belongs_to :dance_style
  belongs_to :dance_level
  belongs_to :instructor, class_name: 'User'
  belongs_to :location
  has_many :class_schedules, dependent: :destroy
  has_many :bookings, through: :class_schedules

  # Validations
  validates :name, presence: true
  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }
  validates :max_capacity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :class_type, presence: true, inclusion: { 
    in: ['regular', 'drop_in', 'practice_party', 'workshop'] 
  }

  # Scopes
  scope :regular_classes, -> { where(class_type: 'regular') }
  scope :drop_in_classes, -> { where(class_type: 'drop_in') }
  scope :practice_parties, -> { where(class_type: 'practice_party') }
  scope :workshops, -> { where(class_type: 'workshop') }

  # Instance methods
  def to_s
    "#{name} - #{dance_style.name} #{dance_level.name}"
  end

  def requires_booking?
    class_type == 'regular'
  end

  def drop_in?
    class_type == 'drop_in'
  end

  def practice_party?
    class_type == 'practice_party'
  end

  def duration_formatted
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

  def price_with_membership_discount(user)
    if user&.has_membership?
      price * (1 - user.membership_discount_decimal)
    else
      price
    end
  end
end
