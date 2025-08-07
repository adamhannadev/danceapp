require 'rails_helper'

RSpec.describe "dance_categories/new", type: :view do
  before(:each) do
    assign(:dance_category, DanceCategory.new(
      name: "MyString"
    ))
  end

  it "renders new dance_category form" do
    render

    assert_select "form[action=?][method=?]", dance_categories_path, "post" do

      assert_select "input[name=?]", "dance_category[name]"
    end
  end
end
