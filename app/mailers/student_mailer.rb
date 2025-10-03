class StudentMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    
    mail(
      to: @user.email,
      subject: "Welcome to #{ENV.fetch('STUDIO_NAME', 'DanceApp')}!"
    )
  end

  def progress_update(user, progress_notes, instructor)
    @user = user
    @progress_notes = progress_notes
    @instructor = instructor
    
    mail(
      to: @user.email,
      subject: "Your Dance Progress Update"
    )
  end

  def competition_invitation(user, event)
    @user = user
    @event = event
    
    mail(
      to: @user.email,
      subject: "Competition Invitation - #{@event.name}"
    )
  end
end
