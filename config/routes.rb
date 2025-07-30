Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by uptime monitors and load balancers.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Root route
  root "dashboard#index"

  # Dashboard
  get "dashboard", to: "dashboard#index"

  # User management
  # Figure management with import
  resources :figures do
    collection do
      get :import
      post :upload_import
    end
  end

  # User management
  resources :users do
    resources :availabilities, controller: 'instructor_availabilities', except: [:show, :edit, :new]
    member do
      patch :toggle_membership
      get :progress_report
    end
    # Nested student progress under users (for admin/instructor access)
    resources :student_progress, only: [:index, :show, :update] do
      member do
        get :mark_progress
        patch :mark_progress
      end
      collection do
        get :enroll
        post :enroll
      end
    end
  end

  # Student progress tracking
  resources :student_progress, only: [:index, :show, :update] do
    member do
      get :mark_progress
      patch :mark_progress
    end
    collection do
      get :all_students  # For admins/instructors to view all student progress
    end
  end

  # Dance classes
  resources :dance_classes do
    resources :class_schedules, except: [:show]
  end

  # Private lessons
  resources :private_lessons do
    member do
      patch :cancel
      patch :confirm
    end
  end

  # Bookings
  resources :bookings do
    member do
      patch :cancel
      patch :confirm
    end
  end

  # Events and registrations
  resources :events do
    resources :event_registrations, except: [:show]
  end

  # Payments and invoicing
  resources :payments do
    collection do
      get :monthly_report
    end
  end

  # Locations
  resources :locations

  # Dance styles and levels
  resources :dance_styles do
    resources :dance_levels, except: [:show]
  end

  # Instructor availability
  resources :instructor_availabilities, except: [:show]

  # Students import (unsecure)
  # resources :students_imports, only: [:new, :create]

  # Waitlists
  resources :waitlists, only: [:index, :create, :destroy]

  # Reports
  namespace :reports do
    get :student_progress
    get :instructor_hours
    get :revenue
    get :class_attendance
  end

  # API endpoints for AJAX requests
  namespace :api do
    namespace :v1 do
      resources :figures, only: [:index, :show]
      resources :student_progress, only: [:update]
      resources :bookings, only: [:create, :update, :destroy]
    end
  end
end
