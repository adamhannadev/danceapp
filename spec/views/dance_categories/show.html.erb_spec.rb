require 'rails_helper'

RSpec.describe "dance_categories/show", type: :view do
  before(:each) do
    assign(:dance_category, DanceCategory.create!(
      name: "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
