import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color secondary = Color(0xFF10B981);
  static const Color accent = Color(0xFFF59E0B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color divider = Color(0xFFE2E8F0);
}

class AppStrings {
  static const String appName = 'JobTrack';
  static const String tagline = 'Find Opportunities. Build Your Career.';
  static const String subtitle = 'Discover government and private jobs and find opportunities that match your skills and qualifications.';
  
  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String mobileNumber = 'Mobile Number';
  static const String educationalQualification = 'Educational Qualification';
  static const String graduationBranch = 'Graduation/Branch';
  static const String graduationYear = 'Graduation Year';
  static const String rememberMe = 'Remember Me';
  static const String forgotPassword = 'Forgot Password?';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";
  
  // Dashboard
  static const String welcome = 'Welcome back';
  static const String welcomeMessage = 'Find the right opportunity. Build your career with JobTrack.';
  static const String governmentJobs = 'Government Jobs';
  static const String privateJobs = 'Private Jobs';
  static const String resumePortal = 'Resume Portal';
  static const String recommendedJobs = 'Recommended Jobs';
  static const String savedJobs = 'Saved Jobs';
  static const String applicationHistory = 'Application History';
  static const String profile = 'Profile';
  static const String recommended = 'Recommended';
  static const String saved = 'Saved';
  static const String applications = 'Applications';
  static const String resumeMatchScore = 'Resume Match Score';
  
  // Jobs
  static const String viewDetails = 'View Details';
  static const String saveJob = 'Save Job';
  static const String apply = 'Apply';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String vacancies = 'Vacancies';
  static const String salary = 'Salary';
  static const String location = 'Location';
  static const String lastDate = 'Last Date';
  static const String qualification = 'Qualification';
  static const String experience = 'Experience';
  static const String skills = 'Skills';
  static const String jobDescription = 'Job Description';
  static const String responsibilities = 'Responsibilities';
  static const String selectionProcess = 'Selection Process';
  
  // Resume
  static const String uploadResume = 'Upload Resume';
  static const String analyzeResume = 'Analyze Resume';
  static const String resumeAnalysis = 'Resume Analysis';
  static const String matchScore = 'Match Score';
  static const String matchedSkills = 'Matched Skills';
  static const String missingSkills = 'Missing Skills';
  static const String whyThisJobMatches = 'Why this job matches';
  static const String skillsToImprove = 'Skills to improve';
  
  // Match Categories
  static const String strongMatch = 'Strong Match';
  static const String partialMatch = 'Partial Match';
  static const String poorMatch = 'Poor Match';
  static const String highlyRecommended = 'Highly Recommended';
  static const String someSkillsMissing = 'Some Skills Missing';
  static const String qualificationNotMet = 'Qualification Requirement Not Met';
  
  // Status
  static const String applied = 'Applied';
  static const String inProgress = 'In Progress';
  static const String shortlisted = 'Shortlisted';
  static const String interview = 'Interview';
  static const String selected = 'Selected';
  static const String closed = 'Closed';
  
  // Buttons
  static const String exploreJobs = 'Explore Jobs';
  static const String getStarted = 'Get Started';
  static const String editProfile = 'Edit Profile';
  static const String updateSkills = 'Update Skills';
  static const String changePassword = 'Change Password';
  static const String remove = 'Remove';
}

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String governmentJobs = '/government-jobs';
  static const String privateJobs = '/private-jobs';
  static const String resumePortal = '/resume-portal';
  static const String recommendedJobs = '/recommended-jobs';
  static const String savedJobs = '/saved-jobs';
  static const String applicationHistory = '/application-history';
  static const String profile = '/profile';
  static const String adminDashboard = '/admin-dashboard';
}

class MatchThresholds {
  static const int strongMatchMin = 75;
  static const int partialMatchMin = 50;
  static const int poorMatchMax = 49;
}
