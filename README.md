# Ballroom Dancing CRM & ERP System

A comprehensive Customer Relationship Management and Enterprise Resource Planning system specifically designed for ballroom dancing schools and studios.

## 🕺 Features

### Student Management
- **Student Registration**: Complete profile management with contact information
- **Digital Waivers**: Required electronic signature before booking
- **Progress Tracking**: Monitor Movement, Timing, and Partnering for each figure
- **Membership Plans**: Monthly memberships with automatic 5% discounts
- **Multi-Location Access**: Students can book at any studio location

### Instructor Management
- **Instructor Profiles**: Certifications, rates, and contact information
- **Availability Management**: Set availability by location and time
- **Progress Marking**: Easy interface to mark student progress on figures
- **Payroll Reports**: Monthly reports for Wave Accounting integration

### Class & Lesson Management
- **Group Classes**: Regular classes with enrollment requirements
- **Private Lessons**: One-on-one instruction scheduling
- **Drop-in Classes**: No advance booking required
- **Practice Parties**: Social dancing opportunities
- **Workshops**: Special instruction events

### Figure (Steps) Management
- **Excel Import**: Import your existing figure database
- **Core vs Variations**: Support for numbered core figures (1, 2, 3) and variations (1a, 1b)
- **Progress Tracking**: Movement, Timing, Partnering assessment for each figure
- **Level-based Access**: Students only see figures for their enrolled levels

### Dance Styles & Levels
- **American Smooth**: Waltz, Tango, Foxtrot
- **American Rhythm**: Cha Cha, Rumba, Swing
- **Social Dances**: West Coast Swing, Salsa, Bachata, Argentine Tango, Kizomba
- **Progressive Levels**: Bronze 1-4, Silver 1-4, Gold 1-4

### Booking & Scheduling
- **Online Booking**: Students can view instructor availability and request times
- **24-Hour Cancellation**: Free cancellation up to 24 hours before
- **Waitlist Management**: Automatic promotion when spots open
- **Capacity Management**: Maximum 20 students per class

### Payment & Invoicing
- **Square Integration**: In-person payment processing
- **Wave Accounting**: Monthly invoice generation and export
- **E-transfer Support**: Canadian e-transfer payment tracking
- **Membership Discounts**: Automatic 5% discount for members

### Events & Competitions
- **Event Management**: Competitions, showcases, social dances
- **Registration System**: Online event sign-ups
- **Team Management**: Competitive dance team organization

### Communication
- **Email Reminders**: 24-hour advance class reminders
- **Newsletter System**: AI-assisted newsletter creation with student spotlights
- **Templates**: Pre-built friendly and enthusiastic communication templates

## 🚀 Quick Start

### Prerequisites
- Ruby 3.x
- PostgreSQL
- Node.js

### Installation

1. **Clone and setup**:
   ```bash
   cd /home/adam/projects/danceapp
   bundle install
   yarn install
   ```

2. **Database setup**:
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed
   ```

3. **Start the server**:
   ```bash
   bin/rails server
   ```

4. **Visit**: http://localhost:3000

### Default Login Credentials

- **Admin**: admin@danceapp.com / password123
- **Instructor 1**: instructor1@danceapp.com / password123
- **Instructor 2**: instructor2@danceapp.com / password123
- **Students**: student1@example.com through student5@example.com / password123

## 📊 Database Schema

### Core Models

- **User**: Students, instructors, and administrators
- **DanceStyle**: American Smooth, Rhythm, Social dances
- **DanceLevel**: Bronze 1-4, Silver 1-4, Gold 1-4
- **Figure**: Individual dance steps with components
- **StudentProgress**: Movement, Timing, Partnering tracking
- **Location**: Studio locations with capacity and hours
- **DanceClass**: Group classes with instructor and location
- **PrivateLesson**: One-on-one instruction
- **Booking**: Class and lesson reservations
- **Payment**: All payment tracking
- **Event**: Competitions, showcases, social events

## 🎯 Key Workflows

### Figure Import Process
1. Use the Excel import feature under Figures
2. Format: Figure Number | Dance Style | Name | Measures | Components | Level
3. Core figures use single numbers (1, 2, 3)
4. Variations use letters (1a, 1b, 2a)

### Student Progress Tracking
1. Instructors access student progress from their dashboard
2. Mark Movement, Timing, and Partnering as pass/fail
3. Figure automatically marked complete when all three pass
4. Students can only see figures for their enrolled levels

### Booking Workflow
1. Students view instructor availability
2. Request specific time slots
3. Admin/instructor can approve or adjust
4. Automatic waitlist if class is full
5. 24-hour cancellation policy enforced

### Monthly Invoicing
1. System generates monthly activity reports
2. Export to Wave Accounting format
3. Send invoices to students
4. Track e-transfer payments

## 🔧 Configuration

### Wave Accounting Integration
- Set up API credentials in `config/credentials.yml.enc`
- Configure automatic invoice generation
- Map payment categories

### Square Payment Integration
- Add Square application ID and access token
- Configure webhook endpoints for payment updates
- Set up sandbox for testing

### Email Configuration
- Configure SMTP settings for reminders
- Set up newsletter templates
- Configure AI writing assistance

## 📈 Reports Available

- **Student Progress**: Individual and class progress reports
- **Instructor Hours**: Monthly teaching time for payroll
- **Revenue Reports**: Payment tracking and forecasting
- **Class Attendance**: Popular classes and capacity utilization

## 🛠️ Development

### Adding New Features

The system is built with extensibility in mind:

- Models use standard Rails associations
- Controllers follow RESTful conventions
- Views use Bootstrap for responsive design
- Background jobs ready for email/notifications

### Testing

```bash
bundle exec rspec
```

### Code Quality

```bash
bundle exec rubocop
bundle exec brakeman
```

## 📞 Support

This system is specifically designed for your ballroom dancing business requirements. All features are tailored to support:

- Your specific dance styles and levels
- Canadian payment methods (e-transfer)
- Wave Accounting integration
- Multi-location growth plans
- Student progress tracking methodology

---

**Built with ❤️ for ballroom dancing excellence**

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
