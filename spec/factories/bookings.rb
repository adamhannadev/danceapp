FactoryBot.define do
  factory :booking do
    user { nil }
    class_schedule { nil }
    booking_type { "MyString" }
    status { "MyString" }
    booked_at { "2025-07-26 09:11:24" }
    cancelled_at { "2025-07-26 09:11:24" }
    payment_status { "MyString" }
  end
end
