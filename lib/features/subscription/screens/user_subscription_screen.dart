import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/plan.dart';
import '../services/plan_service.dart';
import '../services/subscription_service.dart';

class UserSubscriptionScreen extends StatefulWidget {
  const UserSubscriptionScreen({super.key});

  @override
  State<UserSubscriptionScreen> createState() => _UserSubscriptionScreenState();
}

class _UserSubscriptionScreenState extends State<UserSubscriptionScreen> {
  final _sb = Supabase.instance.client;
  final _plans = PlanService();
  final _subs = SubscriptionService();
  late Future<List<Plan>> _futurePlans;
  Map<String, dynamic>? _current;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _futurePlans = _plans.fetchPlans(onlyActive: true);
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    final user = _sb.auth.currentUser;
    if (user == null) return;
    final s = await _subs.getCurrentSubscription(user.id);
    if (mounted) setState(() => _current = s);
  }

  Future<void> _subscribe(Plan p) async {
    final user = _sb.auth.currentUser;
    if (user == null) return;
    setState(() => _loading = true);
    try {
      await _subs.createSubscription(user.id, p.id!);
      await _loadCurrent();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Subscribed to ${p.name}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPlanId = _current?['plan_id'] as String?;
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: FutureBuilder<List<Plan>>(
        future: _futurePlans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final plans = snapshot.data ?? [];
          if (plans.isEmpty) {
            return const Center(child: Text('No plans available'));
          }
          return ListView.separated(
            itemCount: plans.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = plans[i];
              final isCurrent = p.id == currentPlanId;
              return ListTile(
                title: Text(p.name),
                subtitle: Text('${(p.priceCents / 100).toStringAsFixed(2)} ${p.currency} / ${p.interval}'),
                trailing: isCurrent
                    ? const Chip(label: Text('Current'))
                    : ElevatedButton(
                        onPressed: _loading ? null : () => _subscribe(p),
                        child: const Text('Choose'),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
