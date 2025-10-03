require 'ostruct'

# Preview all emails at http://localhost:3000/rails/mailers/student_mailer
class StudentMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/student_mailer/welcome_email
  def welcome_email
    user = User.students.first || create_sample_user('John', 'Doe', 'john@example.com')
    StudentMailer.welcome_email(user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/student_mailer/progress_update
  def progress_update
    user = User.students.first || create_sample_user('Jane', 'Smith', 'jane@example.com')
    instructor = User.instructors.first || create_sample_instructor
    progress_notes = "Great progress on your waltz technique! Your frame has improved significantly, and your timing is much more consistent. Next week we'll work on your promenade and natural turns."
    StudentMailer.progress_update(user, progress_notes, instructor)
  end

  # Preview this email at http://localhost:3000/rails/mailers/student_mailer/competition_invitation
  def competition_invitation
    user = User.students.first || create_sample_user('Sarah', 'Wilson', 'sarah@example.com')
    # Create a mock event object
    event = OpenStruct.new(name: 'Spring Dance Competition', date: 1.month.from_now, location: 'Grand Ballroom')
    StudentMailer.competition_invitation(user, event)
  end

  private

  def create_sample_user(first_name, last_name, email)
    OpenStruct.new(
      first_name: first_name,
      last_name: last_name,
      email: email,
      full_name: "#{first_name} #{last_name}"
    )
  end

  def create_sample_instructor
    OpenStruct.new(
      first_name: 'Michael',
      last_name: 'Teacher',
      email: 'michael@example.com',
      full_name: 'Michael Teacher'
    )
  end

end
