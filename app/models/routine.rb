class Routine < ApplicationRecord
  belongs_to :user  # The student the routine is assigned to
  belongs_to :created_by, class_name: 'User'  # The instructor/admin who created the routine
  belongs_to :dance_category
  belongs_to :dance_style

  # Action Text for rich text description
  has_rich_text :description

  # Validations
  validates :description, presence: true
  validates :user, presence: true
  validates :created_by, presence: true
  validates :dance_category, presence: true
  validates :dance_style, presence: true

  # Scopes
  scope :by_user, ->(user) { where(user: user) }
  scope :by_created_by, ->(user) { where(created_by: user) }
  scope :by_dance_category, ->(category) { where(dance_category: category) }
  scope :by_dance_style, ->(style) { where(dance_style: style) }

  # Instance methods
  def title
    "#{dance_style.name} - #{dance_category.name}"
  end

  def created_by?(current_user)
    created_by == current_user
  end

  def assigned_to?(current_user)
    user == current_user
  end
end
