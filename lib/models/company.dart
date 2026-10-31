class Company {
  final String id;
  final String name;
  final String? logo;
  final String industry;
  final String description;
  final String website;
  final String location;
  final DateTime createdAt;
  final DateTime updatedAt;

  Company({
    required this.id,
    required this.name,
    this.logo,
    required this.industry,
    required this.description,
    required this.website,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'industry': industry,
      'description': description,
      'website': website,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'],
      name: map['name'],
      logo: map['logo'],
      industry: map['industry'],
      description: map['description'],
      website: map['website'],
      location: map['location'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
