import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/student.dart';
import '../models/government_job.dart';
import '../models/private_job.dart';
import '../models/company.dart';
import '../models/application.dart';
import '../models/saved_job.dart';
import '../models/resume.dart';

class SQLiteDatabase {
  static final SQLiteDatabase _instance = SQLiteDatabase._internal();
  factory SQLiteDatabase() => _instance;
  SQLiteDatabase._internal();

  Database? _database;

  // In-memory storage for web platform
  final Map<String, List<Map<String, dynamic>>> _memoryTables = {
    'users': [],
    'students': [],
    'government_jobs': [],
    'private_jobs': [],
    'companies': [],
    'applications': [],
    'saved_jobs': [],
  };

  bool get _isWeb => kIsWeb;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // For web, use in-memory storage via sqflite_common_ffi
    if (_isWeb) {
      await _initializeMemoryDatabase();
      final memoryDatabase = _createMemoryDatabaseProxy();
      await _insertSampleGovernmentJobs(memoryDatabase);
      await _insertSamplePrivateJobs(memoryDatabase);
      await _insertSampleCompanies(memoryDatabase);
      return memoryDatabase;
    }

    // For mobile/desktop, use sqflite
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'jobtrack.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE government_jobs ADD COLUMN official_notification_url TEXT',
          );
          await db.execute(
            'ALTER TABLE government_jobs ADD COLUMN recruiting_organization TEXT',
          );
        }
      },
    );
  }

  Future<void> _initializeMemoryDatabase() async {
    // Initialize sample data
    _memoryTables['users'] = [
      {
        'id': '1',
        'email': 'admin@jobtrack.com',
        'password':
            'sha256\$jobtrack-admin-salt\$da52cdc331a87121e5b44d148819f99a360a925b691c9d0f5a4f44f61ee65a13',
        'role': 'admin',
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    _memoryTables['students'] = [
      {
        'id': '1',
        'user_id': '1',
        'full_name': 'Admin User',
        'email': 'admin@jobtrack.com',
        'mobile_number': '9999999999',
        'educational_qualification': 'B.Tech',
        'graduation_branch': 'Computer Science',
        'graduation_year': '2024',
        'profile_photo': null,
        'experience': 'Fresher',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];
  }

  Database _createMemoryDatabaseProxy() {
    // Return a mock database object for web
    return _MemoryDatabase(_memoryTables);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Students table
    await db.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL,
        mobile_number TEXT NOT NULL,
        educational_qualification TEXT NOT NULL,
        graduation_branch TEXT NOT NULL,
        graduation_year TEXT NOT NULL,
        profile_photo TEXT,
        experience TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Government jobs table
    await db.execute('''
      CREATE TABLE government_jobs (
        id TEXT PRIMARY KEY,
        job_title TEXT NOT NULL,
        organization TEXT NOT NULL,
        job_role TEXT NOT NULL,
        location TEXT NOT NULL,
        educational_qualification TEXT NOT NULL,
        age_eligibility TEXT,
        vacancies INTEGER,
        salary TEXT,
        application_closing_date TEXT NOT NULL,
        application_start_date TEXT,
        official_application_link TEXT,
        official_notification_url TEXT,
        recruiting_organization TEXT,
        required_skills TEXT,
        selection_process TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Private jobs table
    await db.execute('''
      CREATE TABLE private_jobs (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        company_id TEXT NOT NULL,
        location TEXT NOT NULL,
        job_type TEXT NOT NULL,
        experience_required TEXT NOT NULL,
        salary_range TEXT NOT NULL,
        description TEXT,
        requirements TEXT,
        technical_skills TEXT,
        soft_skills TEXT,
        application_closing_date TEXT NOT NULL,
        official_link TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Companies table
    await db.execute('''
      CREATE TABLE companies (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        industry TEXT NOT NULL,
        location TEXT NOT NULL,
        website TEXT,
        description TEXT,
        logo TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Resumes table
    await db.execute('''
      CREATE TABLE resumes (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_name TEXT NOT NULL,
        upload_date TEXT NOT NULL,
        analysis_result TEXT,
        skills TEXT,
        certifications TEXT,
        projects TEXT,
        experience TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
      )
    ''');

    // Job matches table
    await db.execute('''
      CREATE TABLE job_matches (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        job_id TEXT NOT NULL,
        job_type TEXT NOT NULL,
        match_score INTEGER NOT NULL,
        match_category TEXT NOT NULL,
        matched_skills TEXT,
        missing_skills TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
      )
    ''');

    // Applications table
    await db.execute('''
      CREATE TABLE applications (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        job_id TEXT NOT NULL,
        job_type TEXT NOT NULL,
        job_title TEXT NOT NULL,
        company_or_organization TEXT NOT NULL,
        application_date TEXT NOT NULL,
        application_deadline TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
      )
    ''');

    // Saved jobs table
    await db.execute('''
      CREATE TABLE saved_jobs (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        job_id TEXT NOT NULL,
        job_type TEXT NOT NULL,
        saved_at TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
      )
    ''');

    // Insert default admin user
    await db.insert('users', {
      'id': 'admin_001',
      'email': 'admin@jobtrack.com',
      'password':
          'sha256\$jobtrack-admin-salt\$da52cdc331a87121e5b44d148819f99a360a925b691c9d0f5a4f44f61ee65a13',
      'role': 'admin',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Insert sample government jobs
    await _insertSampleGovernmentJobs(db);

    // Insert sample private jobs
    await _insertSamplePrivateJobs(db);

    // Insert sample companies
    await _insertSampleCompanies(db);
  }

  Future<void> _insertSampleGovernmentJobs(Database db) async {
    final jobs = [
      GovernmentJob(
        id: 'gov_001',
        organization: 'State Bank of India',
        jobTitle: 'Probationary Officer',
        vacancies: 2000,
        educationalQualification: 'Graduate in any discipline',
        ageEligibility: '21-30 years',
        salary: '₹36,000 - ₹63,840',
        jobRole: 'Banking',
        responsibilities: 'Banking operations and customer service',
        requiredSkills: ['Banking Knowledge', 'Numerical Ability', 'Reasoning'],
        applicationStartDate: DateTime.now(),
        applicationClosingDate: DateTime.now().add(Duration(days: 30)),
        selectionProcess: 'Preliminary Exam + Main Exam + Interview',
        examinationDetails: 'Online examination',
        officialNotification: 'Available on SBI website',
        officialApplicationLink: 'https://sbi.co.in/careers',
        location: 'All India',
        jobType: 'Full Time',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GovernmentJob(
        id: 'gov_002',
        organization: 'Union Public Service Commission',
        jobTitle: 'Civil Services Examination',
        vacancies: 800,
        educationalQualification: 'Graduate in any discipline',
        ageEligibility: '21-32 years',
        salary: '₹56,100 - ₹2,50,000',
        jobRole: 'Administrative',
        responsibilities:
            'Administrative roles in central and state governments',
        requiredSkills: [
          'General Knowledge',
          'Analytical Skills',
          'Communication',
        ],
        applicationStartDate: DateTime.now(),
        applicationClosingDate: DateTime.now().add(Duration(days: 45)),
        selectionProcess: 'Preliminary Exam + Mains Exam + Interview',
        examinationDetails: 'Three-stage examination',
        officialNotification: 'Available on UPSC website',
        officialApplicationLink: 'https://upsc.gov.in',
        location: 'All India',
        jobType: 'Full Time',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final job in jobs) {
      await db.insert('government_jobs', {
        'id': job.id,
        'job_title': job.jobTitle,
        'organization': job.organization,
        'job_role': job.jobRole,
        'location': job.location,
        'educational_qualification': job.educationalQualification,
        'age_eligibility': job.ageEligibility,
        'vacancies': job.vacancies,
        'salary': job.salary,
        'application_closing_date': job.applicationClosingDate
            .toIso8601String(),
        'application_start_date': job.applicationStartDate.toIso8601String(),
        'official_application_link': job.officialApplicationLink,
        'official_notification_url': job.officialNotificationUrl,
        'recruiting_organization': job.recruitingOrganization,
        'required_skills': job.requiredSkills.join(','),
        'selection_process': job.selectionProcess,
        'created_at': job.createdAt.toIso8601String(),
      });
    }
  }

  Future<void> _insertSamplePrivateJobs(Database db) async {
    final jobs = [
      PrivateJob(
        id: 'priv_001',
        companyId: 'comp_001',
        companyName: 'Tata Consultancy Services',
        companyLogo: null,
        jobRole: 'Software Engineer',
        educationalQualification: 'B.Tech in CS/IT',
        technicalSkills: ['Java', 'Python', 'React', 'SQL'],
        softSkills: ['Communication', 'Teamwork'],
        experience: '0-2 years',
        salary: '₹6,00,000 - ₹10,00,000',
        location: 'Bangalore',
        jobDescription: 'Develop and maintain software applications',
        applicationDeadline: DateTime.now().add(Duration(days: 20)),
        officialApplicationLink: 'https://tcs.com/careers',
        jobType: 'Full-time',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PrivateJob(
        id: 'priv_002',
        companyId: 'comp_002',
        companyName: 'Infosys',
        companyLogo: null,
        jobRole: 'Data Analyst',
        educationalQualification: 'B.Tech/M.Tech in CS/IT',
        technicalSkills: ['Python', 'SQL', 'Tableau', 'Excel'],
        softSkills: ['Problem Solving', 'Communication'],
        experience: '1-3 years',
        salary: '₹8,00,000 - ₹12,00,000',
        location: 'Mumbai',
        jobDescription: 'Analyze data and generate insights',
        applicationDeadline: DateTime.now().add(Duration(days: 25)),
        officialApplicationLink: 'https://infosys.com/careers',
        jobType: 'Full-time',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final job in jobs) {
      await db.insert('private_jobs', {
        'id': job.id,
        'title': job.jobRole,
        'company_id': job.companyId,
        'location': job.location,
        'job_type': job.jobType,
        'experience_required': job.experience,
        'salary_range': job.salary,
        'description': job.jobDescription,
        'requirements': job.educationalQualification,
        'technical_skills': job.technicalSkills.join(','),
        'soft_skills': job.softSkills.join(','),
        'application_closing_date': job.applicationDeadline.toIso8601String(),
        'official_link': job.officialApplicationLink,
        'created_at': job.createdAt.toIso8601String(),
      });
    }
  }

  Future<void> _insertSampleCompanies(Database db) async {
    final companies = [
      Company(
        id: 'comp_001',
        name: 'Tata Consultancy Services',
        industry: 'IT Services',
        location: 'Mumbai',
        website: 'https://tcs.com',
        description: 'Leading IT services company',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Company(
        id: 'comp_002',
        name: 'Infosys',
        industry: 'IT Services',
        location: 'Bangalore',
        website: 'https://infosys.com',
        description: 'Global IT consulting company',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final company in companies) {
      await db.insert('companies', {
        'id': company.id,
        'name': company.name,
        'industry': company.industry,
        'location': company.location,
        'website': company.website,
        'description': company.description,
        'created_at': company.createdAt.toIso8601String(),
      });
    }
  }

  // User operations
  Future<bool> insertUser(User user) async {
    try {
      final db = await database;
      await db.insert('users', {
        'id': user.id,
        'email': user.email.trim().toLowerCase(),
        'password': user.password,
        'role': user.role,
        'created_at': user.createdAt.toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.trim().toLowerCase()],
      );
      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<User?> getUserById(String id) async {
    try {
      final db = await database;
      final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);

      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateUser(User user) async {
    try {
      final db = await database;
      await db.update(
        'users',
        {
          'email': user.email,
          'password': user.password,
          'role': user.role,
          'created_at': user.createdAt.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [user.id],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Student operations
  Future<bool> insertStudent(Student student) async {
    try {
      final db = await database;
      await db.insert('students', {
        'id': student.id,
        'user_id': student.userId,
        'full_name': student.fullName,
        'email': student.email,
        'mobile_number': student.mobileNumber,
        'educational_qualification': student.educationalQualification,
        'graduation_branch': student.graduationBranch,
        'graduation_year': student.graduationYear,
        'profile_photo': student.profilePhoto,
        'experience': student.experience,
        'created_at': student.createdAt.toIso8601String(),
        'updated_at': student.updatedAt.toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Student?> getStudentByUserId(String userId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'students',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      if (maps.isNotEmpty) {
        final map = maps.first;
        return Student(
          id: map['id'] as String,
          userId: map['user_id'] as String,
          fullName: map['full_name'] as String,
          email: map['email'] as String,
          mobileNumber: map['mobile_number'] as String,
          educationalQualification: map['educational_qualification'] as String,
          graduationBranch: map['graduation_branch'] as String,
          graduationYear: map['graduation_year'] as String,
          profilePhoto: map['profile_photo'] as String?,
          skills: [],
          certifications: [],
          projects: [],
          experience: map['experience'] as String,
          createdAt: DateTime.parse(map['created_at'] as String),
          updatedAt: DateTime.parse(map['updated_at'] as String),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateStudent(Student student) async {
    try {
      final db = await database;
      await db.update(
        'students',
        {
          'full_name': student.fullName,
          'mobile_number': student.mobileNumber,
          'educational_qualification': student.educationalQualification,
          'graduation_branch': student.graduationBranch,
          'graduation_year': student.graduationYear,
          'profile_photo': student.profilePhoto,
          'experience': student.experience,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [student.id],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Government jobs operations
  Future<bool> insertGovernmentJob(GovernmentJob job) async {
    try {
      final db = await database;
      await db.insert('government_jobs', {
        'id': job.id,
        'job_title': job.jobTitle,
        'organization': job.organization,
        'job_role': job.jobRole,
        'location': job.location,
        'educational_qualification': job.educationalQualification,
        'age_eligibility': job.ageEligibility,
        'vacancies': job.vacancies,
        'salary': job.salary,
        'application_closing_date': job.applicationClosingDate
            .toIso8601String(),
        'application_start_date': job.applicationStartDate.toIso8601String(),
        'official_application_link': job.officialApplicationLink,
        'official_notification_url': job.officialNotificationUrl,
        'recruiting_organization': job.recruitingOrganization,
        'required_skills': job.requiredSkills.join(','),
        'selection_process': job.selectionProcess,
        'created_at': job.createdAt.toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateGovernmentJob(GovernmentJob job) async {
    try {
      final db = await database;
      await db.update(
        'government_jobs',
        {
          'job_title': job.jobTitle,
          'organization': job.organization,
          'job_role': job.jobRole,
          'location': job.location,
          'educational_qualification': job.educationalQualification,
          'age_eligibility': job.ageEligibility,
          'vacancies': job.vacancies,
          'salary': job.salary,
          'application_closing_date': job.applicationClosingDate
              .toIso8601String(),
          'application_start_date': job.applicationStartDate.toIso8601String(),
          'official_application_link': job.officialApplicationLink,
          'required_skills': job.requiredSkills.join(','),
          'selection_process': job.selectionProcess,
        },
        where: 'id = ?',
        whereArgs: [job.id],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteGovernmentJob(String id) async {
    try {
      final db = await database;
      await db.delete('government_jobs', where: 'id = ?', whereArgs: [id]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<GovernmentJob>> getGovernmentJobs() async {
    try {
      final db = await database;
      final maps = await db.query('government_jobs');
      return maps
          .map(
            (map) => GovernmentJob(
              id: map['id'] as String,
              organization: map['organization'] as String,
              jobTitle: map['job_title'] as String,
              vacancies: map['vacancies'] as int? ?? 0,
              educationalQualification:
                  map['educational_qualification'] as String? ?? '',
              ageEligibility: map['age_eligibility'] as String? ?? '',
              salary: map['salary'] as String? ?? '',
              jobRole: map['job_role'] as String? ?? '',
              responsibilities: '',
              requiredSkills: (map['required_skills'] as String? ?? '')
                  .split(',')
                  .map((s) => s.trim())
                  .toList(),
              applicationStartDate: map['application_start_date'] != null
                  ? DateTime.parse(map['application_start_date'] as String)
                  : DateTime.now(),
              applicationClosingDate: DateTime.parse(
                map['application_closing_date'] as String,
              ),
              selectionProcess: map['selection_process'] as String? ?? '',
              examinationDetails: '',
              officialNotification: '',
              officialNotificationUrl:
                  map['official_notification_url'] as String? ?? '',
              officialApplicationLink:
                  map['official_application_link'] as String? ?? '',
              recruitingOrganization:
                  map['recruiting_organization'] as String? ??
                  map['organization'] as String? ??
                  '',
              location: map['location'] as String? ?? '',
              jobType: 'Full Time',
              createdAt: DateTime.parse(map['created_at'] as String),
              updatedAt: DateTime.now(),
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Private jobs operations
  Future<bool> insertPrivateJob(PrivateJob job) async {
    try {
      final db = await database;
      await db.insert('private_jobs', {
        'id': job.id,
        'title': job.jobRole,
        'company_id': job.companyId,
        'location': job.location,
        'job_type': job.jobType,
        'experience_required': job.experience,
        'salary_range': job.salary,
        'description': job.jobDescription,
        'requirements': job.educationalQualification,
        'technical_skills': job.technicalSkills.join(','),
        'soft_skills': job.softSkills.join(','),
        'application_closing_date': job.applicationDeadline.toIso8601String(),
        'official_link': job.officialApplicationLink,
        'created_at': job.createdAt.toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePrivateJob(PrivateJob job) async {
    try {
      final db = await database;
      await db.update(
        'private_jobs',
        {
          'title': job.jobRole,
          'company_id': job.companyId,
          'location': job.location,
          'job_type': job.jobType,
          'experience_required': job.experience,
          'salary_range': job.salary,
          'description': job.jobDescription,
          'requirements': job.educationalQualification,
          'technical_skills': job.technicalSkills.join(','),
          'soft_skills': job.softSkills.join(','),
          'application_closing_date': job.applicationDeadline.toIso8601String(),
          'official_link': job.officialApplicationLink,
        },
        where: 'id = ?',
        whereArgs: [job.id],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePrivateJob(String id) async {
    try {
      final db = await database;
      await db.delete('private_jobs', where: 'id = ?', whereArgs: [id]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> insertCompany(Company company) async {
    try {
      final db = await database;
      await db.insert('companies', {
        'id': company.id,
        'name': company.name,
        'industry': company.industry,
        'location': company.location,
        'website': company.website,
        'description': company.description,
        'logo': company.logo,
        'created_at': company.createdAt.toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<PrivateJob>> getPrivateJobs() async {
    try {
      final db = await database;
      final maps = await db.query('private_jobs');
      final companies = await db.query('companies');
      final companyNames = {
        for (final company in companies)
          company['id'] as String: company['name'] as String,
      };
      return maps
          .map(
            (map) => PrivateJob(
              id: map['id'] as String,
              companyId: map['company_id'] as String,
              companyName: companyNames[map['company_id'] as String] ?? '',
              companyLogo: null,
              jobRole: map['title'] as String,
              educationalQualification: map['requirements'] as String? ?? '',
              technicalSkills: (map['technical_skills'] as String? ?? '')
                  .split(',')
                  .map((s) => s.trim())
                  .toList(),
              softSkills: (map['soft_skills'] as String? ?? '')
                  .split(',')
                  .map((s) => s.trim())
                  .toList(),
              experience: map['experience_required'] as String,
              salary: map['salary_range'] as String,
              location: map['location'] as String,
              jobDescription: map['description'] as String? ?? '',
              applicationDeadline: DateTime.parse(
                map['application_closing_date'] as String,
              ),
              officialApplicationLink: map['official_link'] as String? ?? '',
              jobType: map['job_type'] as String,
              createdAt: DateTime.parse(map['created_at'] as String),
              updatedAt: DateTime.now(),
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Companies operations
  Future<List<Company>> getCompanies() async {
    try {
      final db = await database;
      final maps = await db.query('companies');
      return maps
          .map(
            (map) => Company(
              id: map['id'] as String,
              name: map['name'] as String,
              industry: map['industry'] as String,
              location: map['location'] as String,
              website: map['website'] as String? ?? '',
              description: map['description'] as String? ?? '',
              createdAt: DateTime.parse(map['created_at'] as String),
              updatedAt: DateTime.now(),
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> countRows(String table) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM $table');
    return (result.first['count'] as int?) ?? 0;
  }

  // Application operations
  Future<bool> insertApplication(Application application) async {
    try {
      final db = await database;
      await db.insert('applications', {
        'id': application.id,
        'student_id': application.studentId,
        'job_id': application.jobId,
        'job_type': application.jobType,
        'job_title': application.jobTitle,
        'company_or_organization': application.companyOrOrganization,
        'application_date': application.applicationDate.toIso8601String(),
        'application_deadline': application.applicationDeadline
            .toIso8601String(),
        'status': application.status,
        'created_at': application.createdAt.toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Application>> getApplicationsByStudentId(String studentId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'applications',
        where: 'student_id = ?',
        whereArgs: [studentId],
        orderBy: 'application_date DESC',
      );
      return maps
          .map(
            (map) => Application(
              id: map['id'] as String,
              studentId: map['student_id'] as String,
              jobId: map['job_id'] as String,
              jobType: map['job_type'] as String,
              jobTitle: map['job_title'] as String,
              companyOrOrganization: map['company_or_organization'] as String,
              applicationDate: DateTime.parse(
                map['application_date'] as String,
              ),
              applicationDeadline: DateTime.parse(
                map['application_deadline'] as String,
              ),
              status: map['status'] as String,
              createdAt: DateTime.parse(map['created_at'] as String),
              updatedAt: DateTime.now(),
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Saved jobs operations
  Future<bool> insertSavedJob(SavedJob savedJob) async {
    try {
      final db = await database;
      await db.insert('saved_jobs', {
        'id': savedJob.id,
        'student_id': savedJob.studentId,
        'job_id': savedJob.jobId,
        'job_type': savedJob.jobType,
        'saved_at': savedJob.savedAt.toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<SavedJob>> getSavedJobsByStudentId(String studentId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'saved_jobs',
        where: 'student_id = ?',
        whereArgs: [studentId],
        orderBy: 'saved_at DESC',
      );
      return maps
          .map(
            (map) => SavedJob(
              id: map['id'] as String,
              studentId: map['student_id'] as String,
              jobId: map['job_id'] as String,
              jobType: map['job_type'] as String,
              jobTitle: 'Job',
              companyOrOrganization: 'Company',
              location: 'Location',
              deadline: DateTime.now(),
              savedAt: DateTime.parse(map['saved_at'] as String),
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteSavedJob(String savedJobId) async {
    try {
      final db = await database;
      await db.delete('saved_jobs', where: 'id = ?', whereArgs: [savedJobId]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSavedJobByJobId(String jobId, String studentId) async {
    try {
      final db = await database;
      await db.delete(
        'saved_jobs',
        where: 'job_id = ? AND student_id = ?',
        whereArgs: [jobId, studentId],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> insertResume(Resume resume) async {
    try {
      final db = await database;
      await db.insert('resumes', {
        'id': resume.id,
        'student_id': resume.studentId,
        'file_path': resume.filePath,
        'file_name': resume.fileName,
        'upload_date': resume.uploadedAt.toIso8601String(),
        'analysis_result': resume.extractedText,
        'skills': jsonEncode(resume.technicalSkills),
        'certifications': jsonEncode(resume.certifications),
        'projects': jsonEncode(resume.projects),
        'experience': resume.experience,
        'created_at': resume.uploadedAt.toIso8601String(),
        'updated_at': resume.analyzedAt.toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Resume?> getResumeByStudentId(String studentId) async {
    try {
      final db = await database;
      final rows = await db.query(
        'resumes',
        where: 'student_id = ?',
        whereArgs: [studentId],
        orderBy: 'upload_date DESC',
        limit: 1,
      );
      if (rows.isEmpty) return null;
      final row = rows.first;
      List<String> decodeList(dynamic value) {
        if (value == null || value.toString().isEmpty) return [];
        return List<String>.from(jsonDecode(value.toString()) as List);
      }

      return Resume(
        id: row['id'] as String,
        studentId: row['student_id'] as String,
        fileName: row['file_name'] as String,
        filePath: row['file_path'] as String,
        fileType: (row['file_name'] as String).toLowerCase().endsWith('.pdf')
            ? 'pdf'
            : 'doc',
        extractedText: row['analysis_result'] as String? ?? '',
        name: '',
        qualification: '',
        degree: '',
        branch: '',
        graduationYear: '',
        technicalSkills: decodeList(row['skills']),
        softSkills: [],
        certifications: decodeList(row['certifications']),
        projects: decodeList(row['projects']),
        experience: row['experience'] as String? ?? '',
        uploadedAt: DateTime.parse(row['upload_date'] as String),
        analyzedAt: DateTime.parse(row['updated_at'] as String),
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteResumeByStudentId(String studentId) async {
    try {
      final db = await database;
      await db.delete('resumes', where: 'student_id = ?', whereArgs: [studentId]);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Aliases for compatibility
  Future<List<Application>> getApplicationsByStudent(String studentId) async {
    return await getApplicationsByStudentId(studentId);
  }

  Future<List<SavedJob>> getSavedJobsByStudent(String studentId) async {
    return await getSavedJobsByStudentId(studentId);
  }

  // Application status update
  Future<bool> updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    try {
      final db = await database;
      await db.update(
        'applications',
        {'status': status},
        where: 'id = ?',
        whereArgs: [applicationId],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

// In-memory database proxy for web support
class _MemoryDatabase implements Database {
  final Map<String, List<Map<String, dynamic>>> tables;

  _MemoryDatabase(this.tables);

  @override
  Database get database => this;

  @override
  Future<T> devInvokeMethod<T>(String method, [Object? arguments]) async {
    throw UnimplementedError();
  }

  @override
  Future<T> devInvokeSqlMethod<T>(
    String method,
    String sql, [
    List<Object?>? arguments,
  ]) async {
    throw UnimplementedError();
  }

  @override
  Future<T> readTransaction<T>(
    Future<T> Function(Transaction txn) action,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    if (!tables.containsKey(table)) return 0;

    int count = 0;
    if (where == null) {
      count = tables[table]!.length;
      tables[table]!.clear();
    } else {
      final toRemove = <Map<String, dynamic>>[];
      for (var row in tables[table]!) {
        if (_matchesWhere(row, where, whereArgs)) {
          toRemove.add(row);
          count++;
        }
      }
      tables[table]!.removeWhere((row) => toRemove.contains(row));
    }
    return count;
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (!tables.containsKey(table)) tables[table] = [];
    tables[table]!.add(values.cast<String, dynamic>());
    return tables[table]!.length;
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    if (!tables.containsKey(table)) return [];

    var results = <Map<String, dynamic>>[...tables[table]!];

    if (where != null) {
      results = results
          .where((row) => _matchesWhere(row, where, whereArgs))
          .toList();
    }

    if (limit != null) {
      final start = offset ?? 0;
      results = results.skip(start).take(limit).toList();
    }

    return results;
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (!tables.containsKey(table)) return 0;

    int count = 0;
    for (int i = 0; i < tables[table]!.length; i++) {
      if (where == null || _matchesWhere(tables[table]![i], where, whereArgs)) {
        tables[table]![i].addAll(values.cast<String, dynamic>());
        count++;
      }
    }
    return count;
  }

  bool _matchesWhere(
    Map<String, dynamic> row,
    String where,
    List<Object?>? whereArgs,
  ) {
    // Simple where clause parsing (e.g., "id = ?" or "email = ? AND role = ?")
    if (where.contains('=?') || where.contains('= ?')) {
      final parts = where.split(RegExp(r'\s+AND\s+|\s+OR\s+'));
      int argIndex = 0;

      for (var part in parts) {
        if (part.contains('=?') || part.contains('= ?')) {
          final fieldParts = part.split(RegExp(r'\s*=\s*\?'));
          final field = fieldParts[0].trim();
          final value = whereArgs?[argIndex];

          if (row[field] != value) {
            return false;
          }
          argIndex++;
        }
      }
      return true;
    }
    return true;
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {}

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) async {
    return action(_TransactionProxy(this));
  }

  @override
  Future<void> close() async {}

  int get lastInsertRowid => 0;

  int get changes => 0;

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async => 0;

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async => 0;

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async => [];

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async => 0;

  @override
  Batch batch() => _BatchProxy(this);

  Future<void> setTransactionSuccessful() async {}

  @override
  bool get isOpen => true;

  @override
  String get path => ':memory:';

  @override
  Future<QueryCursor> queryCursor(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    int? bufferSize,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<QueryCursor> rawQueryCursor(
    String sql,
    List<Object?>? arguments, {
    int? bufferSize,
  }) async {
    throw UnimplementedError();
  }
}

class _BatchProxy implements Batch {
  final _MemoryDatabase db;

  _BatchProxy(this.db);

  void add(String sql, [List<Object?>? arguments]) {}

  @override
  void delete(String table, {String? where, List<Object?>? whereArgs}) {}

  @override
  void execute(String sql, [List<Object?>? arguments]) {}

  @override
  void insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) {}

  @override
  void rawDelete(String sql, [List<Object?>? arguments]) {}

  @override
  void rawInsert(String sql, [List<Object?>? arguments]) {}

  @override
  void rawUpdate(String sql, [List<Object?>? arguments]) {}

  @override
  void query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) {}

  @override
  void rawQuery(String sql, [List<Object?>? arguments]) {}

  @override
  void update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) {}

  @override
  Future<List<Object?>> commit({
    bool? exclusive,
    bool? noResult,
    bool? continueOnError,
  }) async => [];

  @override
  Future<List<Object?>> apply({bool? noResult, bool? continueOnError}) async =>
      [];

  @override
  int get length => 0;
}

class _TransactionProxy implements Transaction {
  final _MemoryDatabase db;

  _TransactionProxy(this.db);

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) {
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    return db.insert(
      table,
      values,
      nullColumnHack: nullColumnHack,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) {
    return db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    return db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) =>
      db.execute(sql, arguments);

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) =>
      db.rawDelete(sql, arguments);

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) =>
      db.rawInsert(sql, arguments);

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) => db.rawQuery(sql, arguments);

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) =>
      db.rawUpdate(sql, arguments);

  @override
  Batch batch() => _BatchProxy(db);

  @override
  Database get database => db;

  @override
  Future<QueryCursor> queryCursor(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    int? bufferSize,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<QueryCursor> rawQueryCursor(
    String sql,
    List<Object?>? arguments, {
    int? bufferSize,
  }) async {
    throw UnimplementedError();
  }
}
