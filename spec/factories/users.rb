FactoryBot.define do
  factory :user do
    email { "MyString" }
    password_digest { "MyString" }
    first_name { "MyString" }
    last_name { "MyString" }
    phone { "MyString" }
    role { "MyString" }
    membership_type { "MyString" }
    membership_discount { "9.99" }
    waiver_signed { false }
    waiver_signed_at { "2025-07-26 09:06:22" }
  end
end
