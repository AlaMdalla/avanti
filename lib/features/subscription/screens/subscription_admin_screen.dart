import 'package:flutter/material.dart';
import '../models/plan.dart';
import '../services/plan_service.dart';
import 'plan_form_screen.dart';

class SubscriptionAdminScreen extends StatefulWidget {
  const SubscriptionAdminScreen({super.key});

  @override
  SubscriptionAdminScreenState createState() => SubscriptionAdminScreenState();
}

class SubscriptionAdminScreenState extends State<SubscriptionAdminScreen> {
  final _service = PlanService();
  late Future<List<Plan>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchPlans(onlyActive: false);
  }

  Future<void> refresh() async {
    setState(() {
      _future = _service.fetchPlans(onlyActive: false);
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Plan>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView(children: const [SizedBox(height: 300), Center(child: Text('No plans'))]),
          );
        }
        return RefreshIndicator(
          onRefresh: refresh,
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = items[i];
              return ListTile(
                title: Text(p.name),
                subtitle: Text('${(p.priceCents / 100).toStringAsFixed(2)} ${p.currency} / ${p.interval}${p.active ? '' : ' (inactive)'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final changed = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PlanFormScreen(initial: p)),
                        );
                        if (changed != null) {
                          // refresh list after edit
                          // ignore: use_build_context_synchronously
                          if (mounted) refresh();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete plan?'),
                                content: Text('Delete "${p.name}"? This action cannot be undone.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                                ],
                              ),
                            ) ??
                            false;
                        if (!ok) return;
                        try {
                          await _service.delete(p.id!);
                          if (mounted) refresh();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
