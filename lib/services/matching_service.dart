import '../models/resume.dart';
import '../models/government_job.dart';
import '../models/private_job.dart';
import '../models/job_match.dart';
import '../utils/helpers.dart';
import 'database_service.dart';

class MatchingService {
  static final MatchingService _instance = MatchingService._internal();
  factory MatchingService() => _instance;
  MatchingService._internal();

  final DatabaseService _database = DatabaseService();

  Future<JobMatch> matchWithGovernmentJob(Resume resume, GovernmentJob job) async {
    int score = 0;
    final matchedSkills = <String>[];
    final missingSkills = <String>[];

    // Qualification match (30 points)
    if (resume.qualification.toLowerCase().contains('bachelor') ||
        resume.qualification.toLowerCase().contains('b.tech') ||
        resume.qualification.toLowerCase().contains('bca')) {
      if (job.educationalQualification.toLowerCase().contains('bachelor') ||
          job.educationalQualification.toLowerCase().contains('b.tech')) {
        score += 30;
      }
    }

    // Skills match (40 points)
    for (final skill in job.requiredSkills) {
      final lowerSkill = skill.toLowerCase();
      if (resume.technicalSkills.any((s) => s.toLowerCase().contains(lowerSkill))) {
        matchedSkills.add(skill);
        score += 10;
      } else {
        missingSkills.add(skill);
      }
    }

    // Experience match (20 points)
    if (resume.experience.toLowerCase() == 'fresher' ||
        resume.experience.toLowerCase().contains('0')) {
      score += 20;
    }

    // Additional factors (10 points)
    score += 10;

    // Cap at 100
    score = score > 100 ? 100 : score;

    final matchCategory = Helpers.getMatchCategory(score);
    final explanation = _generateExplanation(score, matchedSkills, missingSkills, resume.qualification);

    final jobMatch = JobMatch(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      studentId: resume.studentId,
      jobId: job.id,
      jobType: 'government',
      matchScore: score,
      matchedSkills: matchedSkills,
      missingSkills: missingSkills,
      qualificationMatch: score >= 30,
      experienceMatch: resume.experience.toLowerCase() == 'fresher',
      matchCategory: matchCategory,
      explanation: explanation,
      calculatedAt: DateTime.now(),
    );

    await _database.saveJobMatch(jobMatch);
    return jobMatch;
  }

  Future<JobMatch> matchWithPrivateJob(Resume resume, PrivateJob job) async {
    int score = 0;
    final matchedSkills = <String>[];
    final missingSkills = <String>[];

    // Qualification match (25 points)
    if (resume.qualification.toLowerCase().contains('b.tech') ||
        resume.qualification.toLowerCase().contains('bca') ||
        resume.qualification.toLowerCase().contains('b.sc')) {
      if (job.educationalQualification.toLowerCase().contains('b.tech') ||
          job.educationalQualification.toLowerCase().contains('bachelor')) {
        score += 25;
      }
    }

    // Technical skills match (45 points)
    for (final skill in job.technicalSkills) {
      final lowerSkill = skill.toLowerCase();
      if (resume.technicalSkills.any((s) => s.toLowerCase().contains(lowerSkill))) {
        matchedSkills.add(skill);
        score += 15;
      } else {
        missingSkills.add(skill);
      }
    }

    // Experience match (20 points)
    if (resume.experience.toLowerCase() == 'fresher') {
      if (job.experience.toLowerCase().contains('0') ||
          job.experience.toLowerCase().contains('fresher') ||
          job.experience.toLowerCase().contains('entry')) {
        score += 20;
      }
    } else {
      // Check if experience matches
      if (job.experience.toLowerCase().contains(resume.experience.toLowerCase())) {
        score += 20;
      }
    }

    // Soft skills match (10 points)
    for (final skill in job.softSkills) {
      final lowerSkill = skill.toLowerCase();
      if (resume.softSkills.any((s) => s.toLowerCase().contains(lowerSkill))) {
        score += 5;
      }
    }

    // Cap at 100
    score = score > 100 ? 100 : score;

    final matchCategory = Helpers.getMatchCategory(score);
    final explanation = _generateExplanation(score, matchedSkills, missingSkills, resume.qualification);

    final jobMatch = JobMatch(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      studentId: resume.studentId,
      jobId: job.id,
      jobType: 'private',
      matchScore: score,
      matchedSkills: matchedSkills,
      missingSkills: missingSkills,
      qualificationMatch: score >= 25,
      experienceMatch: score >= 20,
      matchCategory: matchCategory,
      explanation: explanation,
      calculatedAt: DateTime.now(),
    );

    await _database.saveJobMatch(jobMatch);
    return jobMatch;
  }

  String _generateExplanation(
    int score,
    List<String> matchedSkills,
    List<String> missingSkills,
    String qualification,
  ) {
    final buffer = StringBuffer();
    
    if (score >= 75) {
      buffer.write('Highly recommended based on strong match. ');
    } else if (score >= 50) {
      buffer.write('Good match with some skills to improve. ');
    } else {
      buffer.write('Partial match - consider improving qualifications. ');
    }
    
    if (matchedSkills.isNotEmpty) {
      buffer.write('Matched skills: ${matchedSkills.join(', ')}. ');
    }
    
    if (missingSkills.isNotEmpty) {
      buffer.write('Skills to improve: ${missingSkills.join(', ')}. ');
    }
    
    return buffer.toString();
  }

  Future<List<JobMatch>> getRecommendedJobs(String studentId) async {
    final matches = await _database.getJobMatches(studentId);
    
    // Sort by match score descending
    matches.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    
    return matches;
  }
}
