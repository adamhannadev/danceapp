class DanceLevel < ApplicationRecord
  # Associations
  belongs_to :dance_style
  has_many :figures, dependent: :destroy
  has_many :dance_classes, dependent: :destroy
  has_many :private_lessons, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :level_number, presence: true, uniqueness: { scope: :dance_style_id }
  validates :level_number, inclusion: { in: 1..12 }

  # Scopes
  scope :bronze, -> { where(level_number: [1, 2, 3, 4], name: /Bronze/) }
  scope :silver, -> { where(level_number: [1, 2, 3, 4], name: /Silver/) }
  scope :gold, -> { where(level_number: [1, 2, 3, 4], name: /Gold/) }
  scope :ordered, -> { order(:level_number) }

  # Instance methods
  def to_s
    "#{name} (#{dance_style.name})"
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
end
