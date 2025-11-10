import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/plan.dart';
import '../services/plan_service.dart';
import 'plan_checkout_confirm_screen.dart';

class UserSubscriptionScreen extends StatefulWidget {
  const UserSubscriptionScreen({super.key});

  @override
  State<UserSubscriptionScreen> createState() => _UserSubscriptionScreenState();
}

class _UserSubscriptionScreenState extends State<UserSubscriptionScreen> {
  final _sb = Supabase.instance.client; // Kept for future use (auth check)
  final _plans = PlanService();
  late Future<List<Plan>> _futurePlans;
  String? _selectedPlanId; // Tracks last tapped plan

  @override
  void initState() {
    super.initState();
    _futurePlans = _plans.fetchPlans(onlyActive: true);
  }

  @override
  Widget build(BuildContext context) {
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
              return ListTile(
                title: Text(p.name),
                subtitle: Text('${(p.priceCents / 100).toStringAsFixed(2)} ${p.currency} / ${p.interval}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    setState(() => _selectedPlanId = p.id);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlanCheckoutConfirmScreen(plan: p),
                      ),
                    );
                  },
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
