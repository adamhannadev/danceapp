require 'ostruct'

# Preview all emails at http://localhost:3000/rails/mailers/booking_mailer
class BookingMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/booking_mailer/booking_confirmation
  def booking_confirmation
    booking = create_sample_booking
    BookingMailer.booking_confirmation(booking)
  end

  # Preview this email at http://localhost:3000/rails/mailers/booking_mailer/booking_reminder
  def booking_reminder
    booking = create_sample_booking
    BookingMailer.booking_reminder(booking)
  end

  # Preview this email at http://localhost:3000/rails/mailers/booking_mailer/class_cancelled
  def class_cancelled
    booking = create_sample_booking
    BookingMailer.class_cancelled(booking, "Instructor illness")
  end

  # Preview this email at http://localhost:3000/rails/mailers/booking_mailer/instructor_assigned
  def instructor_assigned
    booking = create_sample_booking
    BookingMailer.instructor_assigned(booking)
  end

  private

  def create_sample_booking
    user = User.students.first || create_sample_user
    dance_class = DanceClass.first || create_sample_dance_class
    
    # Create a mock booking object with the relationships
    OpenStruct.new(
      user: user,
      dance_class: dance_class,
      id: 1,
      created_at: Time.current
    )
  end

  def create_sample_user
    OpenStruct.new(
      first_name: 'Emma',
      last_name: 'Johnson',
      email: 'emma@example.com',
      full_name: 'Emma Johnson'
    )
  end

  def create_sample_dance_class
    instructor = User.instructors.first || create_sample_instructor
    
    OpenStruct.new(
      name: 'Beginner Waltz',
      start_time: 1.day.from_now.change(hour: 19, min: 0),
      end_time: 1.day.from_now.change(hour: 20, min: 0),
      level: 'beginner',
      description: 'Learn the basics of the elegant waltz. Perfect for beginners!',
      instructor: instructor
    )
  end

  def create_sample_instructor
    OpenStruct.new(
      first_name: 'Roberto',
      last_name: 'Martinez',
      email: 'roberto@example.com',
      full_name: 'Roberto Martinez'
    )
  end

end
