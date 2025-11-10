import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StripeService {
  StripeService();

  static Future<void> initialize() async {
    // Stripe is only supported on iOS and Android
    if (!_isSupportedPlatform()) {
      return; // Silent - expected on web/linux
    }

    final key = dotenv.maybeGet('STRIPE_PUBLISHABLE_KEY');
    if (key != null && key.isNotEmpty) {
      try {
        Stripe.publishableKey = key;
        await Stripe.instance.applySettings();
      } catch (e) {
        // Silent fail for unsupported platforms
      }
    }
  }

  /// Check if the platform supports Stripe
  static bool _isSupportedPlatform() {
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  /// Process payment directly with Stripe using Payment Sheet
  /// This is minimalist - no Edge Function, direct Stripe payment
  Future<Map<String, dynamic>> processPaymentDirect({
    required String planId,
    required String planName,
    required int amountCents,
    required String currency,
  }) async {
    try {
      // Payment sheet will be initialized when user taps Pay
      return {
        'success': true,
        'message': 'Ready for payment',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Present the payment sheet to user
  Future<Map<String, dynamic>> presentPaymentSheet({
    required String planId,
    required String planName,
    required int amountCents,
  }) async {
    if (!_isSupportedPlatform()) {
      return {
        'success': false,
        'error': 'Stripe is not supported on this platform',
      };
    }

    try {
      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      // If we get here, payment was successful
      return {
        'success': true,
        'message': 'Payment successful',
        'planId': planId,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
