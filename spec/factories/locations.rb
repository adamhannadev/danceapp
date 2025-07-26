FactoryBot.define do
  factory :location do
    name { "MyString" }
    address { "MyText" }
    phone { "MyString" }
    capacity { 1 }
    operating_hours { "MyText" }
    active { false }
  end
end
