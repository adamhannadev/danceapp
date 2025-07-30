class StudentsImportsController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    if params[:file].present?
      require 'csv'
      imported = 0
      CSV.foreach(params[:file].path, headers: true) do |row|

        # Skip rows with missing essential data
        next if row['email'].blank? || row['first_name'].blank? || row['last_name'].blank?
        
        # Clean up the email and name fields
        email = row['email'].strip.downcase
        first_name = row['first_name'].strip
        last_name = row['last_name'].strip
        phone = row['phone'].present? ? row['phone'].strip : nil
        
        # Create the student user
        User.find_or_create_by!(email: email) do |user|
        user.password = "password123"
        user.password_confirmation = "password123"
        user.first_name = first_name
        user.last_name = last_name
        user.phone = phone
        user.role = "student"
        user.membership_type = "none"
        user.membership_discount = 0
        user.waiver_signed = false
        user.waiver_signed_at = nil
        end

      end
      redirect_to users_path, notice: "Imported students."
    else
      redirect_to new_students_import_path, alert: "Please select a CSV file."
    end
  end
end
