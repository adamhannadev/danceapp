# Script to create sample student progress data

# Get sample data
student = User.students.first
instructor = User.instructors.first
figures = Figure.all

puts "Student: #{student&.full_name || 'Not found'}"
puts "Instructor: #{instructor&.full_name || 'Not found'}"
puts "Figures: #{figures.count}"

if student && instructor && figures.any?
  figures.each_with_index do |figure, index|
    progress = StudentProgress.find_or_create_by(
      user: student,
      figure: figure,
      instructor: instructor
    ) do |sp|
      # Simulate different progress levels
      case index % 4
      when 0
        # Completed
        sp.movement_passed = true
        sp.timing_passed = true
        sp.partnering_passed = true
        sp.completed_at = 2.days.ago
        sp.notes = 'Great work! All components mastered successfully.'
      when 1
        # Mostly complete
        sp.movement_passed = true
        sp.timing_passed = true
        sp.partnering_passed = false
        sp.notes = 'Movement and timing are solid. Working on partnering skills.'
      when 2
        # Partially complete
        sp.movement_passed = true
        sp.timing_passed = false
        sp.partnering_passed = false
        sp.notes = 'Getting the movement down. Need to work on timing and connection.'
      when 3
        # Just started
        sp.movement_passed = false
        sp.timing_passed = false
        sp.partnering_passed = false
        sp.notes = 'Just starting to learn this figure.'
      end
    end
  end
  
  puts 'Sample student progress data created!'
  puts "Progress entries: #{StudentProgress.count}"
else
  puts 'Missing required data (student, instructor, or figures)'
end
