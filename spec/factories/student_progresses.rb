FactoryBot.define do
  factory :student_progress do
    user { nil }
    figure { nil }
    movement_passed { false }
    timing_passed { false }
    partnering_passed { false }
    completed_at { "2025-07-26 09:09:20" }
    instructor { nil }
  end
end
