import 'package:cloud_firestore/cloud_firestore.dart';

DateTime _parsePrivateJobDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.parse(value.toString());
}

class PrivateJob {
  final String id;
  final String companyId;
  final String companyName;
  final String? companyLogo;
  final String jobRole;
  final String educationalQualification;
  final List<String> technicalSkills;
  final List<String> softSkills;
  final String experience;
  final String salary;
  final String location;
  final String jobDescription;
  final DateTime applicationDeadline;
  final String officialApplicationLink;
  final String jobType;
  final DateTime createdAt;
  final DateTime updatedAt;

  PrivateJob({
    required this.id,
    required this.companyId,
    required this.companyName,
    this.companyLogo,
    required this.jobRole,
    required this.educationalQualification,
    required this.technicalSkills,
    required this.softSkills,
    required this.experience,
    required this.salary,
    required this.location,
    required this.jobDescription,
    required this.applicationDeadline,
    required this.officialApplicationLink,
    required this.jobType,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyId': companyId,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'jobRole': jobRole,
      'educationalQualification': educationalQualification,
      'technicalSkills': technicalSkills,
      'softSkills': softSkills,
      'experience': experience,
      'salary': salary,
      'location': location,
      'jobDescription': jobDescription,
      'applicationDeadline': applicationDeadline.toIso8601String(),
      'officialApplicationLink': officialApplicationLink,
      'jobType': jobType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PrivateJob.fromMap(Map<String, dynamic> map) {
    return PrivateJob(
      id: map['id'],
      companyId: map['companyId'],
      companyName: map['companyName'],
      companyLogo: map['companyLogo'],
      jobRole: map['jobRole'],
      educationalQualification: map['educationalQualification'],
      technicalSkills: List<String>.from(map['technicalSkills'] ?? []),
      softSkills: List<String>.from(map['softSkills'] ?? []),
      experience: map['experience'],
      salary: map['salary'],
      location: map['location'],
      jobDescription: map['jobDescription'],
      applicationDeadline: _parsePrivateJobDate(map['applicationDeadline']),
      officialApplicationLink: map['officialApplicationLink'],
      jobType: map['jobType'],
      createdAt: _parsePrivateJobDate(map['createdAt']),
      updatedAt: _parsePrivateJobDate(map['updatedAt']),
    );
  }
}
