class SavedJob {
  final String id;
  final String studentId;
  final String jobId;
  final String jobType; // 'government' or 'private'
  final String jobTitle;
  final String companyOrOrganization;
  final String location;
  final DateTime deadline;
  final int? matchScore;
  final DateTime savedAt;

  SavedJob({
    required this.id,
    required this.studentId,
    required this.jobId,
    required this.jobType,
    required this.jobTitle,
    required this.companyOrOrganization,
    required this.location,
    required this.deadline,
    this.matchScore,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'jobId': jobId,
      'jobType': jobType,
      'jobTitle': jobTitle,
      'companyOrOrganization': companyOrOrganization,
      'location': location,
      'deadline': deadline.toIso8601String(),
      'matchScore': matchScore,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory SavedJob.fromMap(Map<String, dynamic> map) {
    return SavedJob(
      id: map['id'],
      studentId: map['studentId'],
      jobId: map['jobId'],
      jobType: map['jobType'],
      jobTitle: map['jobTitle'],
      companyOrOrganization: map['companyOrOrganization'],
      location: map['location'],
      deadline: DateTime.parse(map['deadline']),
      matchScore: map['matchScore'],
      savedAt: DateTime.parse(map['savedAt']),
    );
  }
}
