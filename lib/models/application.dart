class Application {
  final String id;
  final String studentId;
  final String jobId;
  final String jobType; // 'government' or 'private'
  final String jobTitle;
  final String companyOrOrganization;
  final DateTime applicationDate;
  final DateTime applicationDeadline;
  final String status; // 'applied', 'in_progress', 'shortlisted', 'interview', 'selected', 'closed'
  final DateTime createdAt;
  final DateTime updatedAt;

  Application({
    required this.id,
    required this.studentId,
    required this.jobId,
    required this.jobType,
    required this.jobTitle,
    required this.companyOrOrganization,
    required this.applicationDate,
    required this.applicationDeadline,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'jobId': jobId,
      'jobType': jobType,
      'jobTitle': jobTitle,
      'companyOrOrganization': companyOrOrganization,
      'applicationDate': applicationDate.toIso8601String(),
      'applicationDeadline': applicationDeadline.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Application.fromMap(Map<String, dynamic> map) {
    return Application(
      id: map['id'],
      studentId: map['studentId'],
      jobId: map['jobId'],
      jobType: map['jobType'],
      jobTitle: map['jobTitle'],
      companyOrOrganization: map['companyOrOrganization'],
      applicationDate: DateTime.parse(map['applicationDate']),
      applicationDeadline: DateTime.parse(map['applicationDeadline']),
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
