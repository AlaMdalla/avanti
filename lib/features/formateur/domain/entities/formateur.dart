class Formateur {
  final String id;
  final String name;
  final String speciality;
  final String email;
  final String? address;
  final DateTime? createdAt;

  Formateur({
    required this.id,
    required this.name,
    required this.speciality,
    required this.email,
    this.address,
    this.createdAt,
  });

  factory Formateur.fromJson(Map<String, dynamic> json) {
    return Formateur(
      id: json['id'] as String,
      name: json['name'] as String,
      speciality: json['speciality'] as String,
      email: json['email'] as String,
      address: json['address'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'speciality': speciality,
      'email': email,
      'address': address,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}