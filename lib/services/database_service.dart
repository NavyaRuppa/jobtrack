import '../models/application.dart';
import '../models/saved_job.dart';
import '../models/resume.dart';
import '../models/job_match.dart';
import 'sqlite_database.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final _db = SQLiteDatabase();

  Future<List<Application>> getApplications(String studentId) async {
    return await _db.getApplicationsByStudentId(studentId);
  }

  Future<List<Application>> getStudentApplications(String studentId) async {
    return await getApplications(studentId);
  }

  Future<bool> saveApplication(Application application) async {
    return await _db.insertApplication(application);
  }

  Future<List<SavedJob>> getSavedJobs(String studentId) async {
    return await _db.getSavedJobsByStudentId(studentId);
  }

  Future<bool> saveSavedJob(SavedJob savedJob) async {
    return await _db.insertSavedJob(savedJob);
  }

  Future<bool> saveJob(SavedJob savedJob) async {
    return await saveSavedJob(savedJob);
  }

  Future<bool> removeSavedJob(String jobId, String studentId) async {
    return await _db.deleteSavedJobByJobId(jobId, studentId);
  }

  Future<void> saveResume(Resume resume) async {
    await _db.deleteResumeByStudentId(resume.studentId);
    await _db.insertResume(resume);
  }

  Future<Resume?> getStudentResume(String studentId) async {
    return await _db.getResumeByStudentId(studentId);
  }

  Future<void> deleteResume(String studentId) async {
    await _db.deleteResumeByStudentId(studentId);
  }

  Future<void> saveJobMatch(JobMatch match) async {
    // Placeholder - job match storage not implemented in SQLite yet
  }

  Future<List<JobMatch>> getJobMatches(String studentId) async {
    // Placeholder - job match retrieval not implemented in SQLite yet
    return [];
  }

  Future<int> getStudentCount() async {
    return await _db.countRows('students');
  }

  Future<int> getApplicationCount() async {
    return await _db.countRows('applications');
  }

  Future<int> getCompanyCount() async {
    return (await _db.getCompanies()).length;
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await _db.database;
    return db.query('students', orderBy: 'full_name ASC');
  }

  Future<List<Map<String, dynamic>>> getCompanies() async {
    return (await _db.getCompanies())
        .map((company) => company.toMap())
        .toList();
  }
}
