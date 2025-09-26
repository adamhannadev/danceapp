class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Set default values
  after_initialize :set_defaults, if: :new_record?

  # Associations
  has_many :student_progresses, dependent: :destroy
  has_many :figures, through: :student_progresses
  has_many :bookings, dependent: :destroy
  has_many :private_lessons_as_student, class_name: 'PrivateLesson', foreign_key: 'student_id', dependent: :destroy
  has_many :private_lessons_as_instructor, class_name: 'PrivateLesson', foreign_key: 'instructor_id', dependent: :destroy
  has_many :dance_classes, foreign_key: 'instructor_id', dependent: :destroy
  has_many :instructor_availabilities, foreign_key: 'instructor_id', dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :event_registrations, dependent: :destroy
  has_many :events, through: :event_registrations
  has_many :waitlists, dependent: :destroy
  has_many :routines, dependent: :destroy

  # Action Text associations
  has_rich_text :goals

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true, inclusion: { in: ['student', 'instructor', 'admin'] }
  validates :membership_type, inclusion: { in: ['none', 'monthly', 'annual'] }
  validates :membership_discount, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  # Scopes
  scope :students, -> { where(role: 'student') }
  scope :instructors, -> { where(role: 'instructor') }
  scope :admins, -> { where(role: 'admin') }
  scope :with_membership, -> { where.not(membership_type: 'none') }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def instructor?
    role == 'instructor'
  end

  def student?
    role == 'student'
  end

  def admin?
    role == 'admin'
  end

  def has_membership?
    membership_type != 'none'
  end

  def membership_discount_decimal
    membership_discount / 100.0 if membership_discount
  end

  # Waiver methods
  def waiver_signed?
    waiver_signed_at.present? && waiver_signed == true
  end

  def needs_waiver?
    !waiver_signed?
  end

  private

  def set_defaults
    self.membership_discount ||= 0
    self.membership_type ||= 'none'
    self.role ||= 'student'
  end
end
