# Email Configuration Documentation

## Overview

This Rails application has been configured with a comprehensive email system that includes:

1. **Devise Authentication Emails** (password reset, confirmation, etc.)
2. **Custom Business Mailers** (welcome emails, booking confirmations, progress updates)
3. **Development Testing** with letter_opener
4. **Production SMTP** configuration

## Development Setup

### Current Configuration

- **Email Delivery**: Uses `letter_opener` gem to open emails in browser
- **Raise Delivery Errors**: `true` (to catch issues during development)
- **Default URL**: `localhost:3000`

### Testing Emails

1. **View in Development**: Emails are saved to `tmp/letter_opener/` and would normally open in browser
2. **Preview Emails**: Visit `http://localhost:3000/rails/mailers` to preview all mailers
3. **Manual Testing**: Use Rails console or runner to send test emails

## Production Setup

### Required Environment Variables

```bash
# Basic Email Settings
MAILER_FROM=noreply@yourdancestudio.com
MAILER_HOST=yourdancestudio.com
APP_URL=https://yourdancestudio.com

# Studio Information
STUDIO_NAME=Your Dance Studio
STUDIO_EMAIL=info@yourdancestudio.com
STUDIO_PHONE=(555) 123-DANCE

# SMTP Configuration (see provider-specific settings below)
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_PORT=587
SMTP_DOMAIN=yourdancestudio.com
SMTP_USERNAME=your_username
SMTP_PASSWORD=your_password
SMTP_AUTHENTICATION=plain
```

### Recommended Email Providers

#### SendGrid (Recommended)
```bash
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USERNAME=apikey
SMTP_PASSWORD=your_sendgrid_api_key
```

#### Mailgun
```bash
SMTP_ADDRESS=smtp.mailgun.org
SMTP_PORT=587
SMTP_USERNAME=your_mailgun_username
SMTP_PASSWORD=your_mailgun_password
```

#### Postmark
```bash
SMTP_ADDRESS=smtp.postmarkapp.com
SMTP_PORT=587
SMTP_USERNAME=your_postmark_server_token
SMTP_PASSWORD=your_postmark_server_token
```

## Available Mailers

### 1. StudentMailer

- **Welcome Email**: Sent automatically when a student registers
- **Progress Update**: Manual email for instructor feedback
- **Competition Invitation**: For competition events

### 2. BookingMailer

- **Booking Confirmation**: Sent when a class is booked
- **Booking Reminder**: For upcoming classes
- **Class Cancelled**: When a class is cancelled
- **Instructor Assigned**: When an instructor is assigned

### 3. Devise Mailer (Built-in)

- **Password Reset**: When user requests password reset
- **Email Confirmation**: If confirmable module is enabled
- **Account Unlock**: If lockable module is enabled

## Email Templates

All emails have both HTML and text versions:
- HTML: Rich formatting with CSS styles
- Text: Plain text fallback for email clients that don't support HTML

### Template Locations
```
app/views/student_mailer/
├── welcome_email.html.erb
├── welcome_email.text.erb
├── progress_update.html.erb
├── progress_update.text.erb
├── competition_invitation.html.erb
└── competition_invitation.text.erb

app/views/booking_mailer/
├── booking_confirmation.html.erb
├── booking_confirmation.text.erb
├── booking_reminder.html.erb
├── booking_reminder.text.erb
├── class_cancelled.html.erb
├── class_cancelled.text.erb
├── instructor_assigned.html.erb
└── instructor_assigned.text.erb
```

## Usage Examples

### Sending Emails Programmatically

```ruby
# Welcome email (sent automatically on user creation)
user = User.find(1)
StudentMailer.welcome_email(user).deliver_now

# Booking confirmation
booking = Booking.find(1)
BookingMailer.booking_confirmation(booking).deliver_now

# Progress update
StudentMailer.progress_update(user, "Great progress!", instructor).deliver_now

# Password reset (handled by Devise)
user.send_reset_password_instructions
```

### Background Job Processing

For production, consider using background jobs:

```ruby
# Instead of deliver_now, use deliver_later
StudentMailer.welcome_email(user).deliver_later
BookingMailer.booking_confirmation(booking).deliver_later
```

## Customization

### Updating Email Templates

1. Edit files in `app/views/[mailer_name]/`
2. Both HTML and text versions should be updated
3. Use instance variables passed from mailer methods

### Adding New Mailer Methods

1. Add method to mailer class (`app/mailers/`)
2. Create corresponding view templates
3. Update mailer preview for testing

### Styling Emails

- Use inline CSS for maximum compatibility
- Keep designs simple and responsive
- Test across multiple email clients

## Troubleshooting

### Common Issues

1. **Emails not sending**: Check SMTP credentials and server connectivity
2. **Delivery errors**: Enable `raise_delivery_errors` in production for debugging
3. **Formatting issues**: Test with both HTML and text email clients
4. **Spam filtering**: Use reputable SMTP provider and proper domain authentication

### Testing Commands

```bash
# Test SMTP connection
rails runner "ActionMailer::Base.smtp_settings"

# Send test email
rails runner "StudentMailer.welcome_email(User.first).deliver_now"

# Check email queue (if using background jobs)
rails runner "puts ActiveJob::Base.queue_adapter"
```

### Monitoring

Consider adding email monitoring for production:
- Track delivery rates
- Monitor bounce rates
- Set up alerts for failed deliveries

## Security Considerations

1. **Environment Variables**: Never commit SMTP credentials to version control
2. **Rate Limiting**: Implement rate limiting for user-triggered emails
3. **Content Validation**: Sanitize any user-generated content in emails
4. **Unsubscribe Links**: Add unsubscribe functionality for marketing emails