require 'rails_helper'

RSpec.describe "dance_categories/index", type: :view do
  before(:each) do
    assign(:dance_categories, [
      DanceCategory.create!(
        name: "Name"
      ),
      DanceCategory.create!(
        name: "Name"
      )
    ])
  end

  it "renders a list of dance_categories" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
  end
end
