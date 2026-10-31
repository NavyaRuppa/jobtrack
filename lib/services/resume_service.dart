import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/resume.dart';
import '../utils/helpers.dart';
import 'database_service.dart';

class ResumeService {
  static final ResumeService _instance = ResumeService._internal();
  factory ResumeService() => _instance;
  ResumeService._internal();

  final DatabaseService _database = DatabaseService();

  Future<File?> pickResume() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result.isNotEmpty && result.first.path != null) {
        return File(result.first.path!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Resume?> analyzeResume(File resumeFile, String studentId) async {
    try {
      // In a real app, you would use a PDF parsing library
      // For this demo, we'll simulate resume analysis with sample data
      
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final resumeDirectory = Directory(
        path.join(documentsDirectory.path, 'jobtrack', 'resumes', studentId),
      );
      await resumeDirectory.create(recursive: true);
      final fileName = path.basename(resumeFile.path);
      final storedFile = await resumeFile.copy(
        path.join(resumeDirectory.path, fileName),
      );
      final fileType = fileName.endsWith('.pdf') ? 'pdf' : 'doc';
      
      // Simulated extracted text (in real app, extract from PDF/DOC)
      final extractedText = '''
John Doe
B.Tech Computer Science
Graduation Year: 2024

Skills:
Java
Python
SQL
HTML
CSS
Flutter
Dart

Experience:
Fresher

Projects:
E-commerce Application
Task Management App
      ''';
      
      // Analyze the resume
      final name = 'John Doe'; // Extract from text
      final qualification = Helpers.extractQualification(extractedText);
      final degree = Helpers.extractDegree(extractedText);
      final branch = Helpers.extractBranch(extractedText);
      final graduationYear = Helpers.extractGraduationYear(extractedText);
      final technicalSkills = Helpers.extractSkills(extractedText);
      final softSkills = ['Communication', 'Teamwork', 'Problem Solving']; // Extract or default
      final certifications = <String>[]; // Extract from text
      final projects = ['E-commerce Application', 'Task Management App']; // Extract from text
      final experience = Helpers.extractExperience(extractedText);
      
      final resume = Resume(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: studentId,
        fileName: fileName,
        filePath: storedFile.path,
        fileType: fileType,
        extractedText: extractedText,
        name: name,
        qualification: qualification,
        degree: degree,
        branch: branch,
        graduationYear: graduationYear,
        technicalSkills: technicalSkills,
        softSkills: softSkills,
        certifications: certifications,
        projects: projects,
        experience: experience,
        uploadedAt: DateTime.now(),
        analyzedAt: DateTime.now(),
      );
      
      // Save to database
      await _database.saveResume(resume);
      
      return resume;
    } catch (e) {
      return null;
    }
  }

  Future<Resume?> getStudentResume(String studentId) async {
    return await _database.getStudentResume(studentId);
  }

  Future<bool> deleteResume(String studentId, String filePath) async {
    try {
      await _database.deleteResume(studentId);
      final file = File(filePath);
      if (await file.exists()) await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Resume?> createSampleResume(String studentId) async {
    // Create a sample resume for demo purposes
    final resume = Resume(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      studentId: studentId,
      fileName: 'sample_resume.pdf',
      filePath: '/path/to/sample_resume.pdf',
      fileType: 'pdf',
      extractedText: 'Sample resume text',
      name: 'Student Name',
      qualification: 'B.Tech',
      degree: 'Computer Science',
      branch: 'Computer Science',
      graduationYear: '2024',
      technicalSkills: ['Java', 'Python', 'SQL', 'Flutter', 'HTML', 'CSS'],
      softSkills: ['Communication', 'Teamwork'],
      certifications: [],
      projects: ['Project 1', 'Project 2'],
      experience: 'Fresher',
      uploadedAt: DateTime.now(),
      analyzedAt: DateTime.now(),
    );
    
    await _database.saveResume(resume);
    return resume;
  }
}
