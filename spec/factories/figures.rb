FactoryBot.define do
  factory :figure do
    figure_number { "MyString" }
    name { "MyString" }
    dance_style { nil }
    dance_level { nil }
    measures { 1 }
    components { "MyText" }
    is_core { false }
  end
end
