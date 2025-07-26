class InstructorAvailability < ApplicationRecord
  belongs_to :instructor
  belongs_to :location
end
