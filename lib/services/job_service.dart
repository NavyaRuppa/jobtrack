import 'package:url_launcher/url_launcher.dart';
import '../models/government_job.dart';
import '../models/private_job.dart';
import '../models/company.dart';
import '../models/application.dart';
import '../models/saved_job.dart';
import 'sqlite_database.dart';
import 'firebase_service.dart';
import 'database_service.dart';
import 'auth_service.dart';
import '../utils/url_validator.dart';

class JobService {
  static final JobService _instance = JobService._internal();
  factory JobService() => _instance;
  JobService._internal();

  final _db = SQLiteDatabase();
  final _database = DatabaseService();
  final _authService = AuthService();

  void _requireAdmin() {
    if (!_authService.isLoggedIn || !_authService.isAdmin) {
      throw StateError('Administrator access is required for this operation.');
    }
  }

  void _requireText(String value, String field) {
    if (value.trim().isEmpty) throw ArgumentError('$field is required.');
  }

  void _validateGovernmentJob(GovernmentJob job) {
    _requireText(job.id, 'Job id');
    _requireText(job.organization, 'Organization');
    _requireText(job.jobTitle, 'Job title');
    _requireText(job.jobRole, 'Job role');
    _requireText(job.location, 'Location');
    final errors = <String, String>{};
    final notificationError = UrlValidator.validateHttpUrl(
      job.officialNotificationUrl,
      fieldName: 'Official notification URL',
    );
    final applyError = UrlValidator.validateHttpUrl(
      job.applyOnlineUrl,
      fieldName: 'Apply online URL',
    );
    if (notificationError != null) errors['officialNotificationUrl'] = notificationError;
    if (applyError != null) errors['applyOnlineUrl'] = applyError;
    if (errors.isNotEmpty) {
      throw FormatException(errors.entries.map((e) => '${e.key}: ${e.value}').join('\n'));
    }
    if (job.vacancies < 1) throw ArgumentError('Vacancies must be positive.');
  }

  void _validatePrivateJob(PrivateJob job) {
    _requireText(job.id, 'Job id');
    _requireText(job.companyName, 'Company');
    _requireText(job.jobRole, 'Job role');
    _requireText(job.location, 'Location');
    _requireText(job.officialApplicationLink, 'Application link');
  }

  Future<GovernmentJob> createGovernmentJob(GovernmentJob job) async {
    _requireAdmin();
    _validateGovernmentJob(job);
    if (FirebaseService.instance.isAvailable) {
      await FirebaseService.instance.firestore!
          .collection('government_jobs')
          .doc(job.id)
          .set(job.toMap());
    } else if (!await _db.insertGovernmentJob(job)) {
      throw StateError('The government job could not be created.');
    }
    return job;
  }

  Future<PrivateJob> createPrivateJob(PrivateJob job) async {
    _requireAdmin();
    _validatePrivateJob(job);
    if (FirebaseService.instance.isAvailable) {
      await FirebaseService.instance.firestore!
          .collection('private_jobs')
          .doc(job.id)
          .set(job.toMap());
    } else if (!await _db.insertPrivateJob(job)) {
      throw StateError('The private job could not be created.');
    }
    return job;
  }

  // Government Jobs
  Future<List<GovernmentJob>> getGovernmentJobs() async {
    if (FirebaseService.instance.isAvailable) {
      final snapshot = await FirebaseService.instance.firestore!
          .collection('government_jobs')
          .get();
      return snapshot.docs
          .map((doc) => GovernmentJob.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    }
    return await _db.getGovernmentJobs();
  }

  Future<bool> saveGovernmentJob(GovernmentJob job) async {
    await createGovernmentJob(job);
    return true;
  }

  Future<bool> updateGovernmentJob(GovernmentJob job) async {
    await _updateGovernmentJobForApi(job);
    return true;
  }

  Future<void> _updateGovernmentJobForApi(GovernmentJob job) async {
    _requireAdmin();
    _validateGovernmentJob(job);
    if (FirebaseService.instance.isAvailable) {
      final data = job.toMap()..remove('id');
      await FirebaseService.instance.firestore!
          .collection('government_jobs')
          .doc(job.id)
          .update(data);
    } else if (!await _db.updateGovernmentJob(job)) {
      throw StateError('The government job could not be updated.');
    }
  }

  Future<GovernmentJob?> getGovernmentJobById(String id) async {
    final jobs = await getGovernmentJobs();
    try {
      return jobs.firstWhere((job) => job.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<GovernmentJob>> searchGovernmentJobs(String query) async {
    final allJobs = await getGovernmentJobs();
    if (query.isEmpty) return allJobs;

    return allJobs.where((job) {
      return job.jobTitle.toLowerCase().contains(query.toLowerCase()) ||
          job.organization.toLowerCase().contains(query.toLowerCase()) ||
          job.jobRole.toLowerCase().contains(query.toLowerCase()) ||
          job.location.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<List<GovernmentJob>> filterGovernmentJobs({
    String? organization,
    String? qualification,
    String? location,
  }) async {
    final allJobs = await getGovernmentJobs();

    return allJobs.where((job) {
      if (organization != null &&
          organization.isNotEmpty &&
          job.organization != organization) {
        return false;
      }
      if (qualification != null &&
          qualification.isNotEmpty &&
          !job.educationalQualification.contains(qualification)) {
        return false;
      }
      if (location != null &&
          location.isNotEmpty &&
          !job.location.contains(location)) {
        return false;
      }
      return true;
    }).toList();
  }

  // Private Jobs
  Future<List<PrivateJob>> getPrivateJobs() async {
    if (FirebaseService.instance.isAvailable) {
      final snapshot = await FirebaseService.instance.firestore!
          .collection('private_jobs')
          .get();
      return snapshot.docs
          .map((doc) => PrivateJob.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    }
    return await _db.getPrivateJobs();
  }

  Future<bool> savePrivateJob(PrivateJob job) async {
    _requireAdmin();
    _validatePrivateJob(job);
    if (FirebaseService.instance.isAvailable) {
      await FirebaseService.instance.firestore!
          .collection('private_jobs')
          .doc(job.id)
          .set(job.toMap());
      return true;
    }
    final companies = await _db.getCompanies();
    if (!companies.any((company) => company.id == job.companyId)) {
      final companySaved = await _db.insertCompany(
        Company(
          id: job.companyId,
          name: job.companyName,
          industry: '',
          description: '',
          website: '',
          location: job.location,
          createdAt: job.createdAt,
          updatedAt: job.updatedAt,
        ),
      );
      if (!companySaved) return false;
    }
    return _db.insertPrivateJob(job);
  }

  Future<bool> updatePrivateJob(PrivateJob job) async {
    _requireAdmin();
    _validatePrivateJob(job);
    if (FirebaseService.instance.isAvailable) {
      final data = job.toMap()..remove('id');
      await FirebaseService.instance.firestore!
          .collection('private_jobs')
          .doc(job.id)
          .update(data);
      return true;
    }
    return _db.updatePrivateJob(job);
  }

  Future<bool> deleteGovernmentJob(String id) async {
    _requireAdmin();
    _requireText(id, 'Job id');
    if (FirebaseService.instance.isAvailable) {
      await FirebaseService.instance.firestore!
          .collection('government_jobs')
          .doc(id)
          .delete();
      return true;
    }
    return _db.deleteGovernmentJob(id);
  }

  Future<bool> deletePrivateJob(String id) async {
    _requireAdmin();
    _requireText(id, 'Job id');
    if (FirebaseService.instance.isAvailable) {
      await FirebaseService.instance.firestore!
          .collection('private_jobs')
          .doc(id)
          .delete();
      return true;
    }
    return _db.deletePrivateJob(id);
  }

  Future<PrivateJob?> getPrivateJobById(String id) async {
    final jobs = await getPrivateJobs();
    try {
      return jobs.firstWhere((job) => job.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<PrivateJob>> searchPrivateJobs(String query) async {
    final allJobs = await getPrivateJobs();
    if (query.isEmpty) return allJobs;

    return allJobs.where((job) {
      return job.jobRole.toLowerCase().contains(query.toLowerCase()) ||
          job.companyName.toLowerCase().contains(query.toLowerCase()) ||
          job.location.toLowerCase().contains(query.toLowerCase()) ||
          job.jobDescription.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<List<PrivateJob>> filterPrivateJobs({
    String? company,
    String? location,
    String? experience,
    String? skillFilter,
  }) async {
    final allJobs = await getPrivateJobs();

    return allJobs.where((job) {
      if (company != null && company.isNotEmpty && job.companyId != company) {
        return false;
      }
      if (location != null &&
          location.isNotEmpty &&
          !job.location.contains(location)) {
        return false;
      }
      if (experience != null &&
          experience.isNotEmpty &&
          !job.experience.contains(experience)) {
        return false;
      }
      if (skillFilter != null && skillFilter.isNotEmpty) {
        final skillLower = skillFilter.toLowerCase();
        if (!job.technicalSkills.any(
              (s) => s.toLowerCase().contains(skillLower),
            ) &&
            !job.softSkills.any((s) => s.toLowerCase().contains(skillLower))) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // Companies
  Future<List<Company>> getCompanies() async {
    return await _db.getCompanies();
  }

  // Applications
  Future<bool> applyForJob({
    required String studentId,
    required String jobId,
    required String jobType,
    required String jobTitle,
    required String companyOrOrganization,
    required DateTime applicationDeadline,
  }) async {
    try {
      final application = Application(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: studentId,
        jobId: jobId,
        jobType: jobType,
        jobTitle: jobTitle,
        companyOrOrganization: companyOrOrganization,
        applicationDate: DateTime.now(),
        applicationDeadline: applicationDeadline,
        status: 'applied',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return await _database.saveApplication(application);
    } catch (e) {
      return false;
    }
  }

  Future<List<Application>> getApplicationsByStudent(String studentId) async {
    try {
      return await _database.getApplications(studentId);
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    try {
      if (FirebaseService.instance.isAvailable) {
        await FirebaseService.instance.firestore!
            .collection('applications')
            .doc(applicationId)
            .update({
              'status': status,
              'updatedAt': DateTime.now().toIso8601String(),
            });
        return true;
      }
      return await _db.updateApplicationStatus(applicationId, status);
    } catch (e) {
      return false;
    }
  }

  // Saved Jobs
  Future<bool> saveJob({
    required String studentId,
    required String jobId,
    required String jobType,
    required String jobTitle,
    required String companyOrOrganization,
    required String location,
    required DateTime deadline,
    int? matchScore,
  }) async {
    try {
      final savedJob = SavedJob(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: studentId,
        jobId: jobId,
        jobType: jobType,
        jobTitle: jobTitle,
        companyOrOrganization: companyOrOrganization,
        location: location,
        deadline: deadline,
        matchScore: matchScore,
        savedAt: DateTime.now(),
      );
      return await _database.saveSavedJob(savedJob);
    } catch (e) {
      return false;
    }
  }

  Future<List<SavedJob>> getSavedJobsByStudent(String studentId) async {
    try {
      return await _database.getSavedJobs(studentId);
    } catch (e) {
      return [];
    }
  }

  Future<bool> removeSavedJob(String savedJobId) async {
    try {
      if (FirebaseService.instance.isAvailable) {
        await FirebaseService.instance.firestore!
            .collection('saved_jobs')
            .doc(savedJobId)
            .delete();
        return true;
      }
      return await _db.deleteSavedJob(savedJobId);
    } catch (e) {
      return false;
    }
  }

  Future<bool> isJobSaved(String studentId, String jobId) async {
    try {
      final savedJobs = await getSavedJobsByStudent(studentId);
      return savedJobs.any((job) => job.jobId == jobId);
    } catch (e) {
      return false;
    }
  }

  // URL operations
  Future<void> openApplicationLink(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // External URL launch failures should not interrupt the application flow.
    }
  }

  // Helpers for filters
  Future<List<String>> getAllOrganizations() async {
    try {
      final jobs = await getGovernmentJobs();
      return jobs.map((job) => job.organization).toSet().toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getAllCompanies() async {
    try {
      final jobs = await getPrivateJobs();
      return jobs.map((job) => job.companyName).toSet().toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getAllLocations() async {
    try {
      final govJobs = await getGovernmentJobs();
      final privJobs = await getPrivateJobs();
      final locations = <String>{};
      locations.addAll(govJobs.map((job) => job.location));
      locations.addAll(privJobs.map((job) => job.location));
      return locations.toList();
    } catch (e) {
      return [];
    }
  }
}
