FactoryBot.define do
  factory :event_registration do
    user { nil }
    event { nil }
    registration_date { "2025-07-26 09:18:19" }
    payment_status { "MyString" }
    notes { "MyText" }
  end
end
