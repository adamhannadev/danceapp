# Copilot Instructions for Ballroom Dancing CRM/ERP System

<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

## Project Overview
This is a Ruby on Rails application for a ballroom dancing business CRM/ERP system. The application manages:

- **Student Management**: Registration, profiles, progress tracking, lesson history
- **Instructor Management**: Staff profiles, scheduling, availability, certifications
- **Class & Lesson Booking**: Group classes, private lessons, scheduling system
- **Payment Processing**: Invoicing, payment tracking, packages, memberships
- **Competition Management**: Event registration, results tracking, preparation
- **Studio Operations**: Room booking, equipment management, maintenance
- **Reporting & Analytics**: Business insights, financial reports, student progress

## Technical Stack
- **Framework**: Ruby on Rails 7.2+
- **Database**: PostgreSQL
- **Frontend**: Bootstrap 5, Stimulus.js, Turbo
- **Styling**: SCSS with Bootstrap theming
- **Testing**: Rails testing framework

## Code Style Guidelines
- Follow Rails conventions and best practices
- Use semantic HTML and accessible design patterns
- Implement responsive design with Bootstrap classes
- Use Stimulus controllers for interactive components
- Keep controllers thin, models fat
- Use proper validations and associations in models
- Implement proper error handling and user feedback

## Domain-Specific Context
- **Dance Levels**: Beginner, Intermediate, Advanced, Competitive
- **Dance Styles**: Ballroom (Waltz, Tango, Foxtrot, Quickstep), Latin (Cha-cha, Rumba, Samba, Jive, Paso Doble), Social dances
- **Lesson Types**: Private lessons, Group classes, Practice sessions, Competition prep
- **Membership Types**: Drop-in, Monthly packages, Annual memberships, Competition teams
- **Payment Terms**: Per lesson, Monthly packages, Competition fees, Equipment rental

## Key Features to Implement
1. User authentication and role-based access (Admin, Instructor, Student)
2. Dashboard views for different user types
3. Booking and scheduling system with calendar integration
4. Payment processing and invoice generation
5. Student progress tracking and reporting
6. Competition event management
7. Inventory and equipment tracking
8. Email notifications and reminders
9. Mobile-responsive design for on-the-go access
