import 'package:flutter/material.dart';
import '../models/plan.dart';
import 'payment_checkout_screen.dart';

/// A lightweight confirmation screen shown after the user taps "Choose" on a plan.
/// It summarizes the plan and allows the user to continue to payment or cancel.
class PlanCheckoutConfirmScreen extends StatelessWidget {
  final Plan plan;
  final VoidCallback? onConfirm; // Optional callback before navigation
  final VoidCallback? onCancel;

  const PlanCheckoutConfirmScreen({
    super.key,
    required this.plan,
    this.onConfirm,
    this.onCancel,
  });

  String get priceDisplay => '${(plan.priceCents / 100).toStringAsFixed(2)} ${plan.currency} / ${plan.interval}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Plan')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(priceDisplay, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (plan.description != null) ...[
              Text(plan.description!, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
            ],
            const Divider(),
            const SizedBox(height: 16),
            Text('Please confirm you want to subscribe to this plan. You will be redirected to payment.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      onCancel?.call();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onConfirm?.call();
                      // Navigate to existing payment checkout screen.
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => PaymentCheckoutScreen(plan: plan),
                        ),
                      );
                    },
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

