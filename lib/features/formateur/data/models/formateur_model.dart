import '../../domain/entities/formateur.dart';

class FormateurModel extends Formateur {
  FormateurModel({
    required super.id,
    required super.name,
    required super.email,
    required super.speciality,
    super.createdAt,
  });

  factory FormateurModel.fromJson(Map<String, dynamic> json) => FormateurModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        speciality: json['speciality'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'speciality': speciality,
        'created_at': createdAt?.toIso8601String(),
      };
}
