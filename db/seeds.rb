# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "🕺 Seeding Ballroom Dancing CRM..."

# Create Dance Styles
puts "Creating Dance Styles..."
smooth_styles = [
  { name: 'Waltz', category: 'American Smooth' },
  { name: 'Tango', category: 'American Smooth' },
  { name: 'Foxtrot', category: 'American Smooth' }
]

rhythm_styles = [
  { name: 'Cha Cha', category: 'American Rhythm' },
  { name: 'Rumba', category: 'American Rhythm' },
  { name: 'Swing', category: 'American Rhythm' }
]

social_styles = [
  { name: 'West Coast Swing', category: 'Social' },
  { name: 'Salsa', category: 'Social' },
  { name: 'Bachata', category: 'Social' },
  { name: 'Argentine Tango', category: 'Social' },
  { name: 'Kizomba', category: 'Social' }
]

all_styles = smooth_styles + rhythm_styles + social_styles

all_styles.each do |style_attrs|
  DanceStyle.find_or_create_by!(name: style_attrs[:name]) do |style|
    style.category = style_attrs[:category]
    style.description = "#{style_attrs[:name]} - #{style_attrs[:category]}"
  end
end

# Create Dance Levels for each style
puts "Creating Dance Levels..."
level_data = [
  { name: 'Bronze 1', number: 1 },
  { name: 'Bronze 2', number: 2 },
  { name: 'Bronze 3', number: 3 },
  { name: 'Bronze 4', number: 4 },
  { name: 'Silver 1', number: 5 },
  { name: 'Silver 2', number: 6 },
  { name: 'Silver 3', number: 7 },
  { name: 'Silver 4', number: 8 },
  { name: 'Gold 1', number: 9 },
  { name: 'Gold 2', number: 10 },
  { name: 'Gold 3', number: 11 },
  { name: 'Gold 4', number: 12 }
]

level_data.each do |level_info|
  DanceLevel.find_or_create_by!(
    name: level_info[:name],
    level_number: level_info[:number]
  ) do |level|
    level.description = "#{level_info[:name]} difficulty level"
  end
end


# Create Location
puts "Creating Location..."
main_location = Location.find_or_create_by!(name: "Main Studio") do |location|
  location.address = "123 Dance Street, Dance City, DC 12345"
  location.phone = "(555) 123-DANCE"
  location.capacity = 20
  location.operating_hours = "Monday-Friday: 10am-5pm, Saturday: 9am-6pm, Sunday: Closed"
  location.active = true
end

# Create Admin User
puts "Creating Admin User..."
admin = User.find_or_create_by!(email: "admin@danceapp.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.first_name = "Admin"
  user.last_name = "User"
  user.phone = "(555) 123-4567"
  user.role = "admin"
  user.membership_type = "none"
  user.membership_discount = 0
  user.waiver_signed = true
  user.waiver_signed_at = Time.current
end

# Create Sample Instructors
puts "Creating Sample Instructors..."
instructor1 = User.find_or_create_by!(email: "adam@danceapp.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.first_name = "Adam"
  user.last_name = "Hanna"
  user.phone = "(555) 234-5678"
  user.role = "instructor"
  user.membership_type = "none"
  user.membership_discount = 0
  user.waiver_signed = true
  user.waiver_signed_at = Time.current
end

instructor2 = User.find_or_create_by!(email: "tyna@danceapp.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.first_name = "Tyna"
  user.last_name = "Kottova"
  user.phone = "(555) 345-6789"
  user.role = "instructor"
  user.membership_type = "none"
  user.membership_discount = 0
  user.waiver_signed = true
  user.waiver_signed_at = Time.current
end

# Create Sample Students
puts "Creating Sample Students..."
5.times do |i|
  User.find_or_create_by!(email: "student#{i+1}@example.com") do |user|
    user.password = "password123"
    user.password_confirmation = "password123"
    user.first_name = "Student#{i+1}"
    user.last_name = "Example"
    user.phone = "(555) #{100+i}#{200+i}-#{300+i}#{400+i}"
    user.role = "student"
    user.membership_type = i.even? ? "monthly" : "none"
    user.membership_discount = i.even? ? 5.0 : 0
    user.waiver_signed = true
    user.waiver_signed_at = Time.current
  end
end

# Create Figures from CSV Data
puts "Creating Figures from CSV data..."
require 'csv'

csv_file_path = Rails.root.join('db', 'data', 'br_smooth.csv')

if File.exist?(csv_file_path)
  CSV.foreach(csv_file_path, headers: true) do |row|
    dance_style = DanceStyle.find_by(name: row['dance_style'])
    dance_level = DanceLevel.find_by(name: row['dance_level'])
    
    if dance_style && dance_level
      # Determine if figure is core based on figure_number
      # Core figures have only numbers (1, 2, 3), non-core have letters (1a, 1b, 2a, etc.)
      is_core = row['figure_number'].match?(/^\d+$/)
      
      Figure.find_or_create_by!(
        figure_number: row['figure_number'],
        dance_style: dance_style,
        dance_level: dance_level
      ) do |figure|
        figure.name = row['name']
        figure.measures = row['measures'].to_i
        figure.is_core = is_core
        figure.components = row['components']
      end
    else
      puts "Warning: Could not find dance style '#{row['dance_style']}' or dance level '#{row['dance_level']}' for figure #{row['figure_number']}"
    end
  end
  puts "✅ Figures loaded from CSV successfully!"
else
  puts "⚠️  CSV file not found at #{csv_file_path}, creating sample figures instead..."
  
  # Fallback to sample figures if CSV doesn't exist
  waltz = DanceStyle.find_by(name: 'Waltz')
  bronze1 = DanceLevel.find_by(name: 'Bronze 1')

  if waltz && bronze1
    sample_figures = [
      { number: '1', name: 'Box Step', measures: 2, core: true, components: 'Forward, Side, Together, Back, Side, Together' },
      { number: '2', name: 'Progressive Basic', measures: 2, core: true, components: 'Forward, Side, Together, Forward, Side, Together' },
      { number: '3', name: 'Left Turn', measures: 2, core: true, components: 'Forward, Side, Together, Turn, Side, Together' },
      { number: '1a', name: 'Box Step with Underarm Turn', measures: 2, core: false, components: 'Box Step, Lead Underarm Turn' }
    ]

    sample_figures.each do |fig|
      Figure.find_or_create_by!(
        figure_number: fig[:number],
        dance_style: waltz,
        dance_level: bronze1
      ) do |figure|
        figure.name = fig[:name]
        figure.measures = fig[:measures]
        figure.is_core = fig[:core]
        figure.components = fig[:components]
      end
    end
  end
end

puts "✅ Seeding completed successfully!"
puts ""
puts "📊 Summary:"
puts "Dance Styles: #{DanceStyle.count}"
puts "Dance Levels: #{DanceLevel.count}"
puts "Figures: #{Figure.count}"
puts "Locations: #{Location.count}"
puts "Users: #{User.count}"
puts "  - Admins: #{User.admins.count}"
puts "  - Instructors: #{User.instructors.count}"
puts "  - Students: #{User.students.count}"
puts ""
puts "🔑 Login Credentials:"
puts "Admin: admin@danceapp.com / password123"
puts "Instructor 1: adam@danceapp.com / password123"
puts "Instructor 2: tyna@danceapp.com / password123"
puts "Students: student1@example.com through student5@example.com / password123"
