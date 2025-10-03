class BookingMailer < ApplicationMailer
  def booking_confirmation(booking)
    @booking = booking
    @user = booking.user
    @dance_class = booking.dance_class
    
    mail(
      to: @user.email,
      subject: "Booking Confirmation - #{@dance_class.name}"
    )
  end

  def booking_reminder(booking)
    @booking = booking
    @user = booking.user
    @dance_class = booking.dance_class
    
    mail(
      to: @user.email,
      subject: "Reminder: #{@dance_class.name} - Tomorrow"
    )
  end

  def class_cancelled(booking, reason = nil)
    @booking = booking
    @user = booking.user
    @dance_class = booking.dance_class
    @reason = reason
    
    mail(
      to: @user.email,
      subject: "Class Cancelled - #{@dance_class.name}"
    )
  end

  def instructor_assigned(booking)
    @booking = booking
    @user = booking.user
    @dance_class = booking.dance_class
    @instructor = @dance_class.instructor
    
    mail(
      to: @user.email,
      subject: "Instructor Assigned - #{@dance_class.name}"
    )
  end
end
