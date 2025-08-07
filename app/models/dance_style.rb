class DanceStyle < ApplicationRecord
  # Associations
  has_many :figures, dependent: :destroy
  has_many :dance_classes, dependent: :destroy
  has_many :private_lessons, dependent: :destroy
  has_one :dance_category

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :category, presence: true, inclusion: { 
    in: ['American Smooth', 'American Rhythm', 'Social', 'International Standard', 'International Latin'] 
  }

  # Scopes
  scope :smooth, -> { where(category: 'American Smooth') }
  scope :rhythm, -> { where(category: 'American Rhythm') }
  scope :social, -> { where(category: 'Social') }

  # Instance methods
  def to_s
    name
  end
end
