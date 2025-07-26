class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :class_schedule
end
