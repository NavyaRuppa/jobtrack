class Student {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String mobileNumber;
  final String educationalQualification;
  final String graduationBranch;
  final String graduationYear;
  final String? profilePhoto;
  final List<String> skills;
  final List<String> certifications;
  final List<String> projects;
  final String experience;
  final String preferredJobType;
  final String preferredLocation;
  final DateTime createdAt;
  final DateTime updatedAt;

  Student({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.educationalQualification,
    required this.graduationBranch,
    required this.graduationYear,
    this.profilePhoto,
    required this.skills,
    required this.certifications,
    required this.projects,
    required this.experience,
    this.preferredJobType = '',
    this.preferredLocation = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'mobileNumber': mobileNumber,
      'educationalQualification': educationalQualification,
      'graduationBranch': graduationBranch,
      'graduationYear': graduationYear,
      'profilePhoto': profilePhoto,
      'skills': skills,
      'certifications': certifications,
      'projects': projects,
      'experience': experience,
      'preferredJobType': preferredJobType,
      'preferredLocation': preferredLocation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      userId: map['userId'],
      fullName: map['fullName'],
      email: map['email'],
      mobileNumber: map['mobileNumber'],
      educationalQualification: map['educationalQualification'],
      graduationBranch: map['graduationBranch'],
      graduationYear: map['graduationYear'],
      profilePhoto: map['profilePhoto'],
      skills: List<String>.from(map['skills'] ?? []),
      certifications: List<String>.from(map['certifications'] ?? []),
      projects: List<String>.from(map['projects'] ?? []),
      experience: map['experience'],
      preferredJobType: map['preferredJobType']?.toString() ?? '',
      preferredLocation: map['preferredLocation']?.toString() ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
