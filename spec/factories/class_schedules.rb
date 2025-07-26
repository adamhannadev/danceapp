FactoryBot.define do
  factory :class_schedule do
    dance_class { nil }
    start_datetime { "2025-07-26 09:10:12" }
    end_datetime { "2025-07-26 09:10:12" }
    recurring { false }
    recurrence_pattern { "MyText" }
    active { false }
  end
end
