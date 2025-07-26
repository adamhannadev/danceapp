FactoryBot.define do
  factory :private_lesson do
    student { nil }
    instructor { nil }
    dance_style { nil }
    dance_level { nil }
    location { nil }
    scheduled_at { "2025-07-26 09:11:53" }
    duration_minutes { 1 }
    price { "9.99" }
    status { "MyString" }
    notes { "MyText" }
  end
end
