class Resume {
  final String id;
  final String studentId;
  final String fileName;
  final String filePath;
  final String fileType; // 'pdf' or 'doc'
  final String extractedText;
  final String name;
  final String qualification;
  final String degree;
  final String branch;
  final String graduationYear;
  final List<String> technicalSkills;
  final List<String> softSkills;
  final List<String> certifications;
  final List<String> projects;
  final String experience;
  final DateTime uploadedAt;
  final DateTime analyzedAt;

  Resume({
    required this.id,
    required this.studentId,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.extractedText,
    required this.name,
    required this.qualification,
    required this.degree,
    required this.branch,
    required this.graduationYear,
    required this.technicalSkills,
    required this.softSkills,
    required this.certifications,
    required this.projects,
    required this.experience,
    required this.uploadedAt,
    required this.analyzedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'fileName': fileName,
      'filePath': filePath,
      'fileType': fileType,
      'extractedText': extractedText,
      'name': name,
      'qualification': qualification,
      'degree': degree,
      'branch': branch,
      'graduationYear': graduationYear,
      'technicalSkills': technicalSkills,
      'softSkills': softSkills,
      'certifications': certifications,
      'projects': projects,
      'experience': experience,
      'uploadedAt': uploadedAt.toIso8601String(),
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }

  factory Resume.fromMap(Map<String, dynamic> map) {
    return Resume(
      id: map['id'],
      studentId: map['studentId'],
      fileName: map['fileName'],
      filePath: map['filePath'],
      fileType: map['fileType'],
      extractedText: map['extractedText'],
      name: map['name'],
      qualification: map['qualification'],
      degree: map['degree'],
      branch: map['branch'],
      graduationYear: map['graduationYear'],
      technicalSkills: List<String>.from(map['technicalSkills'] ?? []),
      softSkills: List<String>.from(map['softSkills'] ?? []),
      certifications: List<String>.from(map['certifications'] ?? []),
      projects: List<String>.from(map['projects'] ?? []),
      experience: map['experience'],
      uploadedAt: DateTime.parse(map['uploadedAt']),
      analyzedAt: DateTime.parse(map['analyzedAt']),
    );
  }
}
