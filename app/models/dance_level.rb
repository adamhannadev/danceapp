class DanceLevel < ApplicationRecord
  # Associations
  has_many :figures, dependent: :destroy
  has_many :dance_classes, dependent: :destroy
  has_many :private_lessons, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :level_number, presence: true, uniqueness: true
  validates :level_number, inclusion: { in: 1..12 }

  # Scopes
  scope :bronze, -> { where(level_number: [1, 2, 3, 4]) }
  scope :silver, -> { where(level_number: [5, 6, 7, 8]) }
  scope :gold, -> { where(level_number: [9, 10, 11, 12]) }
  scope :ordered, -> { order(:level_number) }

  # Instance methods
  def to_s
    name
  end

  def bronze?
    name.include?('Bronze')
  end

  def silver?
    name.include?('Silver')
  end

  def gold?
    name.include?('Gold')
  end
  
  def level_category
    case level_number
    when 1..4
      'Bronze'
    when 5..8
      'Silver'
    when 9..12
      'Gold'
    end
  end
  
  def level_within_category
    case level_number
    when 1, 5, 9
      1
    when 2, 6, 10
      2
    when 3, 7, 11
      3
    when 4, 8, 12
      4
    end
  end
end
