import 'package:meta/meta.dart';

@immutable
class Plan {
  final String? id;
  final String name;
  final String? description;
  final int priceCents; // smallest currency unit
  final String currency; // ISO4217 e.g. USD
  final String interval; // 'month' | 'year'
  final bool active;
  final DateTime? createdAt;

  const Plan({
    this.id,
    required this.name,
    this.description,
    required this.priceCents,
    required this.currency,
    required this.interval,
    this.active = true,
    this.createdAt,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json['id'] as String?,
        name: json['name'] as String,
        description: json['description'] as String?,
        priceCents: (json['price_cents'] as num).toInt(),
        currency: json['currency'] as String,
        interval: json['interval'] as String,
        active: json['active'] as bool? ?? true,
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'description': description,
        'price_cents': priceCents,
        'currency': currency,
        'interval': interval,
        'active': active,
      };

  Plan copyWith({
    String? id,
    String? name,
    String? description,
    int? priceCents,
    String? currency,
    String? interval,
    bool? active,
    DateTime? createdAt,
  }) => Plan(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        priceCents: priceCents ?? this.priceCents,
        currency: currency ?? this.currency,
        interval: interval ?? this.interval,
        active: active ?? this.active,
        createdAt: createdAt ?? this.createdAt,
      );
}
