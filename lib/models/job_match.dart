class JobMatch {
  final String id;
  final String studentId;
  final String jobId;
  final String jobType; // 'government' or 'private'
  final int matchScore;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final bool qualificationMatch;
  final bool experienceMatch;
  final String matchCategory; // 'strong', 'partial', 'poor'
  final String explanation;
  final DateTime calculatedAt;

  JobMatch({
    required this.id,
    required this.studentId,
    required this.jobId,
    required this.jobType,
    required this.matchScore,
    required this.matchedSkills,
    required this.missingSkills,
    required this.qualificationMatch,
    required this.experienceMatch,
    required this.matchCategory,
    required this.explanation,
    required this.calculatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'jobId': jobId,
      'jobType': jobType,
      'matchScore': matchScore,
      'matchedSkills': matchedSkills,
      'missingSkills': missingSkills,
      'qualificationMatch': qualificationMatch,
      'experienceMatch': experienceMatch,
      'matchCategory': matchCategory,
      'explanation': explanation,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  factory JobMatch.fromMap(Map<String, dynamic> map) {
    return JobMatch(
      id: map['id'],
      studentId: map['studentId'],
      jobId: map['jobId'],
      jobType: map['jobType'],
      matchScore: map['matchScore'],
      matchedSkills: List<String>.from(map['matchedSkills'] ?? []),
      missingSkills: List<String>.from(map['missingSkills'] ?? []),
      qualificationMatch: map['qualificationMatch'],
      experienceMatch: map['experienceMatch'],
      matchCategory: map['matchCategory'],
      explanation: map['explanation'],
      calculatedAt: DateTime.parse(map['calculatedAt']),
    );
  }
}
