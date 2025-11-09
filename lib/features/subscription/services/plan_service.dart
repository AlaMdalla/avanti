import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/plan.dart';

class PlanService {
  final SupabaseClient _client;
  static const String table = 'plans';

  PlanService([SupabaseClient? client]) : _client = client ?? Supabase.instance.client;

  Future<List<Plan>> fetchPlans({bool onlyActive = true, int limit = 50, int offset = 0}) async {
    var builder = _client.from(table).select();
    if (onlyActive) {
      builder = builder.eq('active', true); // apply filters while still a PostgrestFilterBuilder
    }
    final data = await builder
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    final list = data as List<dynamic>;
    return list.map((e) => Plan.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Plan> create(Plan plan) async {
  final inserted = await _client.from(table).insert(plan.toJson()).select().single();
  return Plan.fromJson(inserted);
  }

  Future<Plan> update(Plan plan) async {
    if (plan.id == null) throw ArgumentError('Plan id required for update');
  final updated = await _client.from(table).update(plan.toJson()).eq('id', plan.id!).select().single();
  return Plan.fromJson(updated);
  }

  Future<void> delete(String id) async {
    await _client.from(table).delete().eq('id', id);
  }
}
