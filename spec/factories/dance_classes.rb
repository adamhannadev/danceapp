FactoryBot.define do
  factory :dance_class do
    name { "MyString" }
    dance_style { nil }
    dance_level { nil }
    instructor { nil }
    location { nil }
    duration_minutes { 1 }
    max_capacity { 1 }
    price { "9.99" }
    description { "MyText" }
    class_type { "MyString" }
  end
end
