class Figure < ApplicationRecord
  # Associations
  belongs_to :dance_style
  belongs_to :dance_level
  has_many :student_progresses, dependent: :destroy
  has_many :students, through: :student_progresses, source: :user

  # Validations
  validates :figure_number, presence: true, uniqueness: { scope: [:dance_style_id, :dance_level_id] }
  validates :name, presence: true
  validates :measures, presence: true, numericality: { greater_than: 0 }

  # Scopes
  scope :core_figures, -> { where(is_core: true) }
  scope :variations, -> { where(is_core: false) }
  scope :by_number, -> { order(:figure_number) }

  # Instance methods
  def to_s
    "#{figure_number} - #{name}"
  end

  def core_figure?
    is_core
  end

  def variation?
    !is_core
  end

  def components_list
    components.split(',').map(&:strip) if components.present?
  end

  def full_description
    "#{dance_style.name} #{dance_level.name}: #{figure_number} - #{name}"
  end
end
