import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/plan.dart';
import '../services/payment_service.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final Plan plan;
  const PaymentCheckoutScreen({super.key, required this.plan});

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  final _sb = Supabase.instance.client;
  final _payment = PaymentService();
  bool _starting = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final user = _sb.auth.currentUser;
    if (user == null) {
      setState(() {
        _error = 'Not authenticated';
        _starting = false;
      });
      return;
    }
    try {
      final url = await _payment.createCheckoutSession(planId: widget.plan.id!, userId: user.id);
      await _payment.openCheckout(url);
      if (!mounted) return;
      setState(() => _starting = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _starting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: _starting
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Opening checkout...'),
                ],
              )
            : _error != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _start(),
                        child: const Text('Retry'),
                      )
                    ],
                  )
                : const Text('Checkout opened in browser. Complete the payment and return.'),
      ),
    );
  }
}
