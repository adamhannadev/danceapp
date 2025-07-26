FactoryBot.define do
  factory :event do
    name { "MyString" }
    event_type { "MyString" }
    location { nil }
    start_date { "2025-07-26" }
    end_date { "2025-07-26" }
    registration_deadline { "2025-07-26" }
    price { "9.99" }
    max_participants { 1 }
    description { "MyText" }
    active { false }
  end
end
