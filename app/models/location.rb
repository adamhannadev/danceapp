class Location < ApplicationRecord
  # Associations
  has_many :dance_classes, dependent: :destroy
  has_many :private_lessons, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :instructor_availabilities, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :address, presence: true
  validates :capacity, presence: true, numericality: { greater_than: 0 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # Instance methods
  def to_s
    name
  end

  def available_capacity
    capacity
  end

  def operating_hours_formatted
    operating_hours
  end
end
