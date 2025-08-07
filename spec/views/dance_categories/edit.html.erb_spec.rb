require 'rails_helper'

RSpec.describe "dance_categories/edit", type: :view do
  let(:dance_category) {
    DanceCategory.create!(
      name: "MyString"
    )
  }

  before(:each) do
    assign(:dance_category, dance_category)
  end

  it "renders the edit dance_category form" do
    render

    assert_select "form[action=?][method=?]", dance_category_path(dance_category), "post" do

      assert_select "input[name=?]", "dance_category[name]"
    end
  end
end
