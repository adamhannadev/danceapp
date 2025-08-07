require "rails_helper"

RSpec.describe DanceCategoriesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/dance_categories").to route_to("dance_categories#index")
    end

    it "routes to #new" do
      expect(get: "/dance_categories/new").to route_to("dance_categories#new")
    end

    it "routes to #show" do
      expect(get: "/dance_categories/1").to route_to("dance_categories#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/dance_categories/1/edit").to route_to("dance_categories#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/dance_categories").to route_to("dance_categories#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/dance_categories/1").to route_to("dance_categories#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/dance_categories/1").to route_to("dance_categories#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/dance_categories/1").to route_to("dance_categories#destroy", id: "1")
    end
  end
end
