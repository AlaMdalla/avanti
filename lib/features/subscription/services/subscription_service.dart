import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/plan.dart';

class SubscriptionService {
  final SupabaseClient _client;
  static const String plansTable = 'plans';
  static const String subsTable = 'subscriptions';

  SubscriptionService([SupabaseClient? client]) : _client = client ?? Supabase.instance.client;

  Future<List<Plan>> listActivePlans() async {
    final data = await _client
        .from(plansTable)
        .select()
        .eq('active', true)
        .order('price_cents', ascending: true);
    final list = data as List<dynamic>;
    return list.map((e) => Plan.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>?> getCurrentSubscription(String userId) async {
    final data = await _client
        .from(subsTable)
        .select()
        .eq('user_id', userId)
        .order('start_date', ascending: false)
        .limit(1)
        .maybeSingle();
    return data as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>> createSubscription(String userId, String planId) async {
    final inserted = await _client
        .from(subsTable)
        .insert({'user_id': userId, 'plan_id': planId, 'status': 'active'})
        .select()
        .single();
    return inserted as Map<String, dynamic>;
  }
}
