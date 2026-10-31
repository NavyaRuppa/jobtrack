import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'firebase_service.dart';
import '../models/user.dart';
import '../models/student.dart';
import 'sqlite_database.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _db = SQLiteDatabase();
  User? _currentUser;
  Student? _currentStudent;
  String? _lastLoginError;
  String? _lastRegistrationError;

  User? get currentUser => _currentUser;
  Student? get currentStudent => _currentStudent;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isStudent => _currentUser?.role == 'student';
  String? get lastLoginError => _lastLoginError;
  String? get lastRegistrationError => _lastRegistrationError;

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String mobileNumber,
    required String educationalQualification,
    required String graduationBranch,
    required String graduationYear,
    String skills = '',
    String preferredJobType = '',
    String preferredLocation = '',
    String role = 'student',
  }) async {
    _lastRegistrationError = null;
    final normalizedEmail = email.trim().toLowerCase();
    try {
      // Public registration can never grant administrator privileges.
      role = role == 'admin' ? 'student' : role;
      final firebase = FirebaseService.instance;
      if (firebase.isAvailable) {
        final credential = await firebase.auth!.createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
        final firebaseUser = credential.user;
        if (firebaseUser == null) {
          _lastRegistrationError = 'Unable to create the account.';
          return false;
        }

        final now = DateTime.now();
        await firebase.firestore!
            .collection('users')
            .doc(firebaseUser.uid)
            .set({
              'id': firebaseUser.uid,
              'email': normalizedEmail,
              'role': role,
              'fullName': fullName,
              'mobileNumber': mobileNumber,
              'educationalQualification': educationalQualification,
              'graduationBranch': graduationBranch,
              'graduationYear': graduationYear,
              'experience': 'Fresher',
              'skills': skills
                  .split(',')
                  .map((skill) => skill.trim())
                  .where((skill) => skill.isNotEmpty)
                  .toList(),
              'preferredJobType': preferredJobType,
              'preferredLocation': preferredLocation,
              'certifications': <String>[],
              'projects': <String>[],
              'createdAt': now.toIso8601String(),
              'updatedAt': now.toIso8601String(),
            });
        _currentUser = User(
          id: firebaseUser.uid,
          email: normalizedEmail,
          password: '',
          role: role,
          createdAt: now,
        );
        await _loadStudentProfile(firebaseUser.uid);
        await _saveSession();
        return true;
      }

      // Initialize database
      await _db.database;

      // Check if user already exists
      final existingUser = await _db.getUserByEmail(normalizedEmail);
      if (existingUser != null) {
        _lastRegistrationError =
            'This account already exists. Please log in.';
        return false;
      }

      // Create new user
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: normalizedEmail,
        password: _hashPassword(password),
        role: role,
        createdAt: DateTime.now(),
      );

      // Save user to SQLite
      final userSaved = await _db.insertUser(user);
      if (!userSaved) {
        _lastRegistrationError = 'Unable to save your account. Please try again.';
        return false;
      }

      // Create student profile if role is student
      if (role == 'student') {
        final student = Student(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user.id,
          fullName: fullName,
          email: normalizedEmail,
          mobileNumber: mobileNumber,
          educationalQualification: educationalQualification,
          graduationBranch: graduationBranch,
          graduationYear: graduationYear,
          skills: skills
              .split(',')
              .map((skill) => skill.trim())
              .where((skill) => skill.isNotEmpty)
              .toList(),
          certifications: [],
          projects: [],
          experience: 'Fresher',
          preferredJobType: preferredJobType,
          preferredLocation: preferredLocation,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final studentSaved = await _db.insertStudent(student);
        if (!studentSaved) {
          _lastRegistrationError = 'Unable to save your profile. Please try again.';
          return false;
        }
      }

      _currentUser = user;
      await _loadStudentProfile(user.id);
      await _saveSession();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _lastRegistrationError = e.code == 'email-already-in-use'
          ? 'This account already exists. Please log in.'
          : e.message ?? 'Unable to create the account. Please try again.';
      return false;
    } catch (e) {
      _lastRegistrationError = 'Unable to create the account. Please try again.';
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _lastLoginError = null;
    final normalizedEmail = email.trim().toLowerCase();
    try {
      final firebase = FirebaseService.instance;
      if (firebase.isAvailable) {
        final credential = await firebase.auth!.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
        final firebaseUser = credential.user;
        if (firebaseUser == null) {
          _lastLoginError = 'No account was returned by Firebase.';
          return false;
        }

        final snapshot = await firebase.firestore!
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        final data = snapshot.data() ?? <String, dynamic>{};
        _currentUser = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? normalizedEmail,
          password: '',
          role: data['role']?.toString() ?? 'student',
          createdAt:
              DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
              DateTime.now(),
        );
        if (_currentUser!.role == 'student') {
          _currentStudent = Student(
            id: firebaseUser.uid,
            userId: firebaseUser.uid,
            fullName: data['fullName']?.toString() ?? '',
            email: _currentUser!.email,
            mobileNumber: data['mobileNumber']?.toString() ?? '',
            educationalQualification:
                data['educationalQualification']?.toString() ?? '',
            graduationBranch: data['graduationBranch']?.toString() ?? '',
            graduationYear: data['graduationYear']?.toString() ?? '',
            profilePhoto: data['profilePhoto']?.toString(),
            skills: List<String>.from(data['skills'] ?? const <String>[]),
            certifications: List<String>.from(
              data['certifications'] ?? const <String>[],
            ),
            projects: List<String>.from(data['projects'] ?? const <String>[]),
            experience: data['experience']?.toString() ?? 'Fresher',
            preferredJobType: data['preferredJobType']?.toString() ?? '',
            preferredLocation: data['preferredLocation']?.toString() ?? '',
            createdAt:
                DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
                DateTime.now(),
            updatedAt:
                DateTime.tryParse(data['updatedAt']?.toString() ?? '') ??
                DateTime.now(),
          );
        }
        return true;
      }

      final user = await _db.getUserByEmail(normalizedEmail);

      if (user != null && user.password == password) {
        _currentUser = user;

        // Load student profile if role is student
        if (_currentUser!.role == 'student') {
          await _loadStudentProfile(_currentUser!.id);
        }

        await _saveSession();
        return true;
      }

      if (user != null && _verifyPassword(password, user.password)) {
        var authenticatedUser = user;
        if (!user.password.startsWith('sha256\$')) {
          authenticatedUser = User(
            id: user.id,
            email: user.email,
            password: _hashPassword(password),
            role: user.role,
            createdAt: user.createdAt,
          );
          await _db.updateUser(authenticatedUser);
        }
        _currentUser = authenticatedUser;
        if (user.role == 'student') {
          await _loadStudentProfile(user.id);
        }
        await _saveSession();
        return true;
      }

      _lastLoginError = user == null
          ? 'No account exists for this email address.'
          : 'The password is incorrect.';
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _lastLoginError = switch (e.code) {
        'user-not-found' => 'No account exists for this email address.',
        'wrong-password' || 'invalid-credential' =>
          'The email or password is incorrect.',
        _ => e.message ?? 'Unable to sign in. Please try again.',
      };
      return false;
    } catch (e) {
      _lastLoginError = 'Unable to sign in. Please try again.';
      return false;
    }
  }

  String _hashPassword(String password) {
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final saltHex = salt.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    final digest = sha256.convert(utf8.encode('$saltHex:$password'));
    return 'sha256\$$saltHex\$${digest.toString()}';
  }

  bool _verifyPassword(String password, String storedPassword) {
    if (storedPassword.startsWith('sha256\$')) {
      final parts = storedPassword.split('\$');
      if (parts.length != 3) return false;
      final digest = sha256.convert(utf8.encode('${parts[1]}:$password'));
      return digest.toString() == parts[2];
    }

    // Upgrade accounts created by older versions on their next successful login.
    return storedPassword == password;
  }

  Future<void> _saveSession() async {
    final user = _currentUser;
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUserId', user.id);
    await prefs.setString('currentUserRole', user.role);
  }

  Future<void> _loadStudentProfile(String userId) async {
    try {
      if (FirebaseService.instance.isAvailable) {
        final snapshot = await FirebaseService.instance.firestore!
            .collection('users')
            .doc(userId)
            .get();
        final data = snapshot.data();
        if (data != null) {
          final now = DateTime.now();
          _currentStudent = Student(
            id: userId,
            userId: userId,
            fullName: data['fullName']?.toString() ?? '',
            email: data['email']?.toString() ?? _currentUser?.email ?? '',
            mobileNumber: data['mobileNumber']?.toString() ?? '',
            educationalQualification:
                data['educationalQualification']?.toString() ?? '',
            graduationBranch: data['graduationBranch']?.toString() ?? '',
            graduationYear: data['graduationYear']?.toString() ?? '',
            profilePhoto: data['profilePhoto']?.toString(),
            skills: List<String>.from(data['skills'] ?? const <String>[]),
            certifications: List<String>.from(
              data['certifications'] ?? const <String>[],
            ),
            projects: List<String>.from(data['projects'] ?? const <String>[]),
            experience: data['experience']?.toString() ?? 'Fresher',
            preferredJobType: data['preferredJobType']?.toString() ?? '',
            preferredLocation: data['preferredLocation']?.toString() ?? '',
            createdAt:
                DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? now,
            updatedAt:
                DateTime.tryParse(data['updatedAt']?.toString() ?? '') ?? now,
          );
        }
        return;
      }

      final student = await _db.getStudentByUserId(userId);
      if (student != null) {
        _currentStudent = student;
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> logout() async {
    try {
      if (FirebaseService.instance.isAvailable) {
        await FirebaseService.instance.auth!.signOut();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentUserId');
      await prefs.remove('currentUserRole');
      _currentUser = null;
      _currentStudent = null;
    } catch (e) {
      // Handle error
    }
  }

  Future<void> loadSession() async {
    try {
      final firebase = FirebaseService.instance;
      if (firebase.isAvailable) {
        final firebaseUser = firebase.auth!.currentUser;
        if (firebaseUser != null) {
          final snapshot = await firebase.firestore!
              .collection('users')
              .doc(firebaseUser.uid)
              .get();
          final data = snapshot.data() ?? <String, dynamic>{};
          _currentUser = User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            password: '',
            role: data['role']?.toString() ?? 'student',
            createdAt:
                DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
                DateTime.now(),
          );
          if (_currentUser!.role == 'student') {
            await _loadStudentProfile(_currentUser!.id);
          }
          return;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('currentUserId');
      final userRole = prefs.getString('currentUserRole');

      if (userId != null && userRole != null) {
        final user = await _db.getUserById(userId);
        if (user != null) {
          _currentUser = user;

          if (userRole == 'student') {
            await _loadStudentProfile(userId);
          }
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<bool> updateStudentProfile({
    required String fullName,
    required String mobileNumber,
    required String educationalQualification,
    required String graduationBranch,
    required String graduationYear,
    String? profilePhoto,
    String? experience,
    List<String>? skills,
    List<String>? certifications,
    List<String>? projects,
  }) async {
    try {
      if (_currentStudent == null) return false;

      final updatedStudent = Student(
        id: _currentStudent!.id,
        userId: _currentStudent!.userId,
        fullName: fullName,
        email: _currentStudent!.email,
        mobileNumber: mobileNumber,
        educationalQualification: educationalQualification,
        graduationBranch: graduationBranch,
        graduationYear: graduationYear,
        profilePhoto: profilePhoto ?? _currentStudent!.profilePhoto,
        skills: skills ?? _currentStudent!.skills,
        certifications: certifications ?? _currentStudent!.certifications,
        projects: projects ?? _currentStudent!.projects,
        experience: experience ?? _currentStudent!.experience,
        preferredJobType: _currentStudent!.preferredJobType,
        preferredLocation: _currentStudent!.preferredLocation,
        createdAt: _currentStudent!.createdAt,
        updatedAt: DateTime.now(),
      );

      if (FirebaseService.instance.isAvailable) {
        await FirebaseService.instance.firestore!
            .collection('users')
            .doc(updatedStudent.userId)
            .set(updatedStudent.toMap(), SetOptions(merge: true));
        _currentStudent = updatedStudent;
        return true;
      }

      final updated = await _db.updateStudent(updatedStudent);
      if (updated) {
        _currentStudent = updatedStudent;
      }
      return updated;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    String? newPassword,
  }) async {
    try {
      if (FirebaseService.instance.isAvailable) {
        await FirebaseService.instance.auth!.sendPasswordResetEmail(
          email: email.trim(),
        );
        return true;
      }

      final user = await _db.getUserByEmail(email);
      if (user == null || newPassword == null || newPassword.isEmpty) {
        return false; // User not found
      }

      final updatedUser = User(
        id: user.id,
        email: user.email,
        password: _hashPassword(newPassword),
        role: user.role,
        createdAt: user.createdAt,
      );

      return await _db.updateUser(updatedUser);
    } catch (e) {
      return false;
    }
  }
}
