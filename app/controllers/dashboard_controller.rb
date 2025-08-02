class DashboardController < ApplicationController
  def index
    if current_user.instructor?
      @students = User.joins(:private_lessons_as_student)
                      .where(private_lessons: { instructor_id: current_user.id })
                      .distinct.order(:first_name, :last_name)
      @private_lessons = current_user.private_lessons_as_instructor.order(scheduled_at: :desc).limit(10)
      @dance_classes = current_user.dance_classes.order(:start_datetime).limit(10)
      @teachers = User.instructors
    else if current_user.admin?
      @students = User.students
      @private_lessons = PrivateLesson.all
      @dance_classes = DanceClass.all
      @teachers = User.instructors
    else
      
    end
  end
  end
end
