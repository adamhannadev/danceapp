class PrivateLesson < ApplicationRecord
  belongs_to :student
  belongs_to :instructor
  belongs_to :dance_style
  belongs_to :dance_level
  belongs_to :location
end
