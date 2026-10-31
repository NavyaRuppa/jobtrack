import 'package:cloud_firestore/cloud_firestore.dart';

DateTime _parseGovernmentJobDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.parse(value.toString());
}

class GovernmentJob {
  final String id;
  final String organization;
  final String jobTitle;
  final int vacancies;
  final String educationalQualification;
  final String ageEligibility;
  final String salary;
  final String jobRole;
  final String responsibilities;
  final List<String> requiredSkills;
  final DateTime applicationStartDate;
  final DateTime applicationClosingDate;
  final String selectionProcess;
  final String examinationDetails;
  final String officialNotificationUrl;
  final String applyOnlineUrl;
  final String recruitingOrganization;
  final String location;
  final String jobType;
  final DateTime createdAt;
  final DateTime updatedAt;

  GovernmentJob({
    required this.id,
    required this.organization,
    required this.jobTitle,
    required this.vacancies,
    required this.educationalQualification,
    required this.ageEligibility,
    required this.salary,
    required this.jobRole,
    required this.responsibilities,
    required this.requiredSkills,
    required this.applicationStartDate,
    required this.applicationClosingDate,
    required this.selectionProcess,
    required this.examinationDetails,
    String? officialNotification,
    String? officialApplicationLink,
    String? officialNotificationUrl,
    String? applyOnlineUrl,
    String? recruitingOrganization,
    required this.location,
    required this.jobType,
    required this.createdAt,
    required this.updatedAt,
  })  : officialNotificationUrl =
            (officialNotificationUrl ?? officialNotification ?? '').trim(),
        applyOnlineUrl = (applyOnlineUrl ?? officialApplicationLink ?? '').trim(),
        recruitingOrganization =
            (recruitingOrganization ?? organization).trim();

  String get officialNotification => officialNotificationUrl;
  String get officialApplicationLink => applyOnlineUrl;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organization': organization,
      'jobTitle': jobTitle,
      'vacancies': vacancies,
      'educationalQualification': educationalQualification,
      'ageEligibility': ageEligibility,
      'salary': salary,
      'jobRole': jobRole,
      'responsibilities': responsibilities,
      'requiredSkills': requiredSkills,
      'applicationStartDate': applicationStartDate.toIso8601String(),
      'applicationClosingDate': applicationClosingDate.toIso8601String(),
      'selectionProcess': selectionProcess,
      'examinationDetails': examinationDetails,
      'officialNotification': officialNotification,
      'officialNotificationUrl': officialNotificationUrl,
      'officialApplicationLink': applyOnlineUrl,
      'applyOnlineUrl': applyOnlineUrl,
      'recruitingOrganization': recruitingOrganization,
      'location': location,
      'jobType': jobType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GovernmentJob.fromMap(Map<String, dynamic> map) {
    return GovernmentJob(
      id: map['id'],
      organization: map['organization'],
      jobTitle: map['jobTitle'],
      vacancies: map['vacancies'],
      educationalQualification: map['educationalQualification'],
      ageEligibility: map['ageEligibility'],
      salary: map['salary'],
      jobRole: map['jobRole'],
      responsibilities: map['responsibilities'],
      requiredSkills: List<String>.from(map['requiredSkills'] ?? []),
      applicationStartDate: _parseGovernmentJobDate(map['applicationStartDate']),
      applicationClosingDate: _parseGovernmentJobDate(
        map['applicationClosingDate'],
      ),
      selectionProcess: map['selectionProcess'],
      examinationDetails: map['examinationDetails'],
      officialNotificationUrl: map['officialNotificationUrl'] ??
          map['officialNotification'] ??
          '',
      applyOnlineUrl:
          map['applyOnlineUrl'] ?? map['officialApplicationLink'] ?? '',
      recruitingOrganization:
          map['recruitingOrganization'] ?? map['organization'] ?? '',
      location: map['location'],
      jobType: map['jobType'],
      createdAt: _parseGovernmentJobDate(map['createdAt']),
      updatedAt: _parseGovernmentJobDate(map['updatedAt']),
    );
  }
}
