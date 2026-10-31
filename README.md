# JobTrack - Student Career & Job Portal

A modern, professional, student-focused JobTrack Career & Job Portal mobile and web application built with Flutter and Dart.

## Features

### Authentication Module
- Student registration with comprehensive form validation
- Secure login system with role-based access (Student/Admin)
- Password validation and email verification
- Session management with persistent login

### Student Dashboard
- Personalized welcome section with career messages
- Dashboard statistics (Recommended Jobs, Saved Jobs, Applications, Resume Match Score)
- Quick access cards for all major modules
- Navigation drawer for easy access to all features

### Government Job Portal
- Browse government jobs from SSC, UPSC, SBI, IBPS, RRB, and more
- Advanced search and filtering (Organization, Qualification, Location, Job Type)
- Detailed job information with official application links
- Save and apply to government jobs

### Private Job Portal
- Explore private sector jobs from TCS, Infosys, Wipro, Accenture, etc.
- Company-based filtering and search
- Job role, location, and experience filters
- Detailed job descriptions with application links

### Resume Portal & Analysis
- Upload resume in PDF or DOC format
- Rule-based resume analysis (qualification, skills, experience extraction)
- Skill identification and categorization
- Resume analysis results display

### Job Matching System
- Rule-based job matching algorithm
- Match score calculation based on skills, qualification, and experience
- Three match categories: Strong Match (75%+), Partial Match (50-74%), Poor Match (<50%)
- Detailed explanation of matches and missing skills

### Recommended Jobs
- Personalized job recommendations based on resume analysis
- Sorted by match percentage
- Clear explanation of why each job is recommended

### Saved Jobs
- Save jobs for later review
- View saved job details
- Remove saved jobs
- Track application deadlines

### Application History
- Track all job applications
- Application status tracking (Applied, In Progress, Shortlisted, Interview, Selected, Closed)
- Application date and deadline information

### Student Profile
- Complete profile management
- View and edit personal information
- Skills and certifications management
- Profile photo upload

### Admin Dashboard
- Platform statistics overview
- Manage government and private jobs
- Manage companies and students
- Send notifications
- Remove expired jobs
- Manage reported jobs

## Technology Stack

- **Frontend**: Flutter, Dart
- **UI Framework**: Material Design 3
- **State Management**: Provider
- **Database**: SharedPreferences (local storage), Firebase-ready architecture
- **File Handling**: File Picker
- **URL Launching**: URL Launcher
- **Date Formatting**: Intl

## Project Structure

```
lib/
├── main.dart
├── models/              # Data models
├── screens/             # UI screens
│   ├── auth/           # Authentication screens
│   ├── dashboard/      # Student dashboard
│   ├── government/     # Government jobs
│   ├── private/        # Private jobs
│   ├── resume/         # Resume portal
│   ├── recommendations/ # Recommended jobs
│   ├── saved/          # Saved jobs
│   ├── applications/   # Application history
│   ├── profile/        # Student profile
│   ├── admin/          # Admin dashboard
│   └── home/           # Landing screen
├── services/           # Business logic services
├── widgets/            # Reusable widgets
└── utils/              # Constants, validators, helpers
```

## Getting Started

### Prerequisites
- Flutter SDK (3.12.2 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extension

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Install dependencies:
```bash
flutter pub get
```

4. Configure Firebase for the platforms you intend to deploy:
   - Run `flutterfire configure` to generate `lib/firebase_options.dart`, or
     provide the native Firebase files (`google-services.json` and
     `GoogleService-Info.plist`) plus the Flutter web configuration.
   - Enable Email/Password Authentication and create the `users`,
     `government_jobs`, `private_jobs`, `saved_jobs`, `applications`, and
     `companies` Firestore collections.
   - Add Firestore security rules that restrict profile, save, and application
     writes to the signed-in user and restrict job management to admins.

   JobTrack initializes Firebase when platform configuration is available. Until
   then it intentionally falls back to the existing local SQLite store, which
   keeps development and Windows builds usable without silently pretending that
   remote data was saved.

5. Run the application:
```bash
flutter run
```

## Usage

### For Students
1. Register with your details
2. Upload your resume for analysis
3. Browse government and private jobs
4. View personalized job recommendations
5. Save and apply to jobs
6. Track your application history

### For Admins
1. Without Firebase configured, login with `admin@jobtrack.com` and `admin123`
2. Manage job listings
3. Open **Manage Students** from the admin dashboard to view registered customer records; tap a student to see full details
4. View platform statistics
5. Send notifications to students
6. Manage reported content

When Firebase is configured, the local demo admin is not used. Create the admin
account in Firebase Authentication, then create a matching document in the
`users` collection with the same UID and `role: "admin"`. The admin can then
open **Manage Students** to view customer profiles allowed by the Firestore
security rules.

## Future Enhancements

- AI/ML integration for advanced resume analysis
- NLP-based semantic job matching
- Real-time notifications
- Chat support
- Video interview integration
- Skill assessment tests
- Career roadmap generation

## Architecture

The application follows a clean architecture pattern with separation of concerns:
- **Models**: Data structures
- **Services**: Business logic and data operations
- **Screens**: UI components
- **Widgets**: Reusable UI components
- **Utils**: Helper functions and constants

The architecture is designed to be easily integrated with Firebase or a REST API backend for production use.

## License

This project is developed for educational purposes.

## Support

For issues and questions, please refer to the Flutter documentation or contact the development team.
