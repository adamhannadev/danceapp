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

# Create Students from CSV Data
puts "Creating Students from CSV data..."
require 'csv'

student_csv_file_path = Rails.root.join('db', 'data', 'student_list.csv')

if File.exist?(student_csv_file_path)
  CSV.foreach(student_csv_file_path, headers: true) do |row|
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
  puts "✅ Students loaded from CSV successfully!"
else
  puts "⚠️  Student CSV file not found at #{student_csv_file_path}, skipping student creation..."
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
# else
#   puts "⚠️  CSV file not found at #{csv_file_path}, creating sample figures instead..."
  
#   # Fallback to sample figures if CSV doesn't exist
#   waltz = DanceStyle.find_by(name: 'Waltz')
#   bronze1 = DanceLevel.find_by(name: 'Bronze 1')

#   if waltz && bronze1
#     sample_figures = [
#       { number: '1', name: 'Box Step', measures: 2, core: true, components: 'Forward, Side, Together, Back, Side, Together' },
#       { number: '2', name: 'Progressive Basic', measures: 2, core: true, components: 'Forward, Side, Together, Forward, Side, Together' },
#       { number: '3', name: 'Left Turn', measures: 2, core: true, components: 'Forward, Side, Together, Turn, Side, Together' },
#       { number: '1a', name: 'Box Step with Underarm Turn', measures: 2, core: false, components: 'Box Step, Lead Underarm Turn' }
#     ]

#     sample_figures.each do |fig|
#       Figure.find_or_create_by!(
#         figure_number: fig[:number],
#         dance_style: waltz,
#         dance_level: bronze1
#       ) do |figure|
#         figure.name = fig[:name]
#         figure.measures = fig[:measures]
#         figure.is_core = fig[:core]
#         figure.components = fig[:components]
#       end
#     end
#   end
end

# Create sample private lessons
puts "Creating sample private lessons..."
if User.students.any? && User.instructors.any? && DanceStyle.any? && DanceLevel.any? && Location.any?
  students = User.students.limit(3)
  instructors = User.instructors.limit(2)
  
  sample_lessons = [
    {
      scheduled_at: 2.days.from_now.change(hour: 14, min: 0),
      duration: 60,
      status: 'scheduled',
      focus_areas: 'Basic timing and posture',
      notes: 'Student is new to ballroom dancing'
    },
    {
      scheduled_at: 3.days.from_now.change(hour: 16, min: 30),
      duration: 45,
      status: 'requested',
      focus_areas: 'Improve leading technique',
      notes: 'Focus on connection and frame'
    },
    {
      scheduled_at: 5.days.from_now.change(hour: 10, min: 0),
      duration: 90,
      status: 'scheduled',
      focus_areas: 'Competition preparation',
      notes: 'Working on Silver level figures'
    },
    {
      scheduled_at: 1.week.from_now.change(hour: 18, min: 0),
      duration: 60,
      status: 'requested',
      focus_areas: 'Footwork and timing',
      notes: 'Student struggling with complex patterns'
    }
  ]

  sample_lessons.each_with_index do |lesson_attrs, index|
    student = students[index % students.count]
    instructor = instructors[index % instructors.count]
    dance_style = DanceStyle.offset(index % DanceStyle.count).first
    dance_level = DanceLevel.where(name: ['Bronze 1', 'Bronze 2', 'Silver 1'].sample).first || DanceLevel.first
    location = Location.first
    
    # Calculate cost based on instructor rate and duration
    cost = (instructor.hourly_rate * (lesson_attrs[:duration] / 60.0)).round(2)
    
    # Apply membership discount if student has one
    if student.membership_type != 'none'
      discount = student.membership_discount / 100.0
      cost *= (1 - discount)
      cost = cost.round(2)
    end

    PrivateLesson.find_or_create_by!(
      student: student,
      instructor: instructor,
      scheduled_at: lesson_attrs[:scheduled_at]
    ) do |lesson|
      lesson.dance_style = dance_style
      lesson.dance_level = dance_level
      lesson.location = location
      lesson.duration = lesson_attrs[:duration]
      lesson.status = lesson_attrs[:status]
      lesson.focus_areas = lesson_attrs[:focus_areas]
      lesson.notes = lesson_attrs[:notes]
      lesson.cost = cost
      lesson.confirmed_at = lesson_attrs[:status] == 'scheduled' ? 1.day.ago : nil
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
puts "Private Lessons: #{PrivateLesson.count}"
puts "Users: #{User.count}"
puts "  - Admins: #{User.admins.count}"
puts "  - Instructors: #{User.instructors.count}"
puts "  - Students: #{User.students.count}"
puts ""
puts "🔑 Login Credentials:"
puts "Admin: admin@danceapp.com / password123"
puts "Instructor 1: adam@danceapp.com / password123"
puts "Instructor 2: tyna@danceapp.com / password123"
puts "Students: All students from CSV with password123 (waiver not signed)"
