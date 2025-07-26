FactoryBot.define do
  factory :payment do
    user { nil }
    amount { "9.99" }
    payment_method { "MyString" }
    transaction_id { "MyString" }
    status { "MyString" }
    payment_date { "2025-07-26 09:13:37" }
    invoice_number { "MyString" }
    description { "MyText" }
  end
end
