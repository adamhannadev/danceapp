class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAILER_FROM', 'noreply@danceapp.onrender.com')
  layout "mailer"
end
