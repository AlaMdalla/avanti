import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/plan.dart';
import '../services/stripe_service.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final Plan plan;
  const PaymentCheckoutScreen({super.key, required this.plan});

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  final _stripe = StripeService();
  bool _processing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    if (!_isStripeSupportedPlatform()) {
      setState(() {
        _error = 'Stripe not supported on this platform';
      });
      return;
    }

    try {
      // Initialize payment sheet
      final result = await _stripe.processPaymentDirect(
        planId: widget.plan.id!,
        planName: widget.plan.name,
        amountCents: widget.plan.priceCents,
        currency: widget.plan.currency,
      );

      if (!result['success']) {
        setState(() {
          _error = result['error'];
        });
      }
    } catch (e) {
      setState(() {
        _error = '$e';
      });
    }
  }

  bool _isStripeSupportedPlatform() {
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  Future<void> _processPayment() async {
    if (_processing) return;
    
    setState(() {
      _processing = true;
      _error = null;
    });

    try {
      // Show payment sheet
      final result = await _stripe.presentPaymentSheet(
        planId: widget.plan.id!,
        planName: widget.plan.name,
        amountCents: widget.plan.priceCents,
      );

      if (!mounted) return;

      if (result['success']) {
        // Payment successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful!')),
        );
        
        // Navigate back to subscription screen
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/subscription',
          (route) => route.isFirst,
        );
      } else {
        setState(() {
          _error = result['error'] ?? 'Payment failed';
          _processing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _processing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Center(
        child: _error != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              )
            : _processing
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Processing payment...'),
                    ],
                  )
                : !_isStripeSupportedPlatform()
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.smartphone, size: 48),
                          const SizedBox(height: 16),
                          const Text('Demo Mode'),
                          const SizedBox(height: 8),
                          Text(
                            'Stripe payments only work on iOS/Android.\n\nPlan: ${widget.plan.name}\nPrice: \$${(widget.plan.priceCents / 100).toStringAsFixed(2)}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              // Simulate payment success for demo
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Demo payment successful!')),
                              );
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/subscription',
                                (route) => route.isFirst,
                              );
                            },
                            child: const Text('Simulate Payment (Demo)'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Go Back'),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.plan.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${(widget.plan.priceCents / 100).toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _processPayment,
                            icon: const Icon(Icons.payment),
                            label: const Text('Pay Now'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
      ),
    );
  }
}

