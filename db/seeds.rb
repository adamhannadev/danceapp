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

DanceStyle.all.each do |dance_style|
  level_data.each do |level_info|
    DanceLevel.find_or_create_by!(
      name: level_info[:name],
      dance_style: dance_style,
      level_number: level_info[:number]
    ) do |level|
      level.description = "#{level_info[:name]} level for #{dance_style.name}"
    end
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
instructor1 = User.find_or_create_by!(email: "instructor1@danceapp.com") do |user|
  user.password = "password123"
  user.first_name = "Maria"
  user.last_name = "Rodriguez"
  user.phone = "(555) 234-5678"
  user.role = "instructor"
  user.membership_type = "none"
  user.membership_discount = 0
  user.waiver_signed = true
  user.waiver_signed_at = Time.current
end

instructor2 = User.find_or_create_by!(email: "instructor2@danceapp.com") do |user|
  user.password = "password123"
  user.first_name = "James"
  user.last_name = "Thompson"
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

# Create Sample Figures for Waltz Bronze 1
puts "Creating Sample Figures..."
waltz = DanceStyle.find_by(name: 'Waltz')
bronze1 = DanceLevel.find_by(name: 'Bronze 1', dance_style: waltz)

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
puts "Instructor 1: instructor1@danceapp.com / password123"
puts "Instructor 2: instructor2@danceapp.com / password123"
puts "Students: student1@example.com through student5@example.com / password123"
