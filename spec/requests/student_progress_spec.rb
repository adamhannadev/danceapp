require 'rails_helper'

RSpec.describe "StudentProgresses", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/student_progress/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/student_progress/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/student_progress/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /mark_progress" do
    it "returns http success" do
      get "/student_progress/mark_progress"
      expect(response).to have_http_status(:success)
    end
  end

end
