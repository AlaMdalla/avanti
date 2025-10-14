import '../../domain/entities/module.dart';

class ModuleModel extends Module {
  ModuleModel({
    required super.id,
    required super.title,
    required super.description,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}
