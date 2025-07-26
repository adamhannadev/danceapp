FactoryBot.define do
  factory :instructor_availability do
    instructor { nil }
    location { nil }
    day_of_week { 1 }
    start_time { "2025-07-26 09:21:39" }
    end_time { "2025-07-26 09:21:39" }
    active { false }
  end
end
