import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymentService {
  final SupabaseClient _client;
  final String functionName;

  PaymentService({SupabaseClient? client, String? functionName})
      : functionName = functionName ?? (dotenv.maybeGet('PAYMENT_FUNCTION_NAME') ?? 'create-checkout-session'),
        _client = client ?? Supabase.instance.client;

  Future<Uri> createCheckoutSession({required String planId, required String userId}) async {
    // If PAYMENT_CHECKOUT_URL is set, build URL client-side and skip function.
    final base = dotenv.maybeGet('PAYMENT_CHECKOUT_URL');
    if (base != null && base.isNotEmpty) {
      final uri = Uri.parse(base).replace(queryParameters: {
        'plan_id': planId,
        'user_id': userId,
      });
      return uri;
    }

    // Fallback to calling the edge function to create a session.
    final res = await _client.functions.invoke(functionName, body: {
      'plan_id': planId,
      'user_id': userId,
    });
    final data = res.data as Map<String, dynamic>;
    final url = data['url'] as String? ?? data['checkout_url'] as String?;
    if (url == null) {
      final status = res.status;
      final error = data['error'] ?? 'Unknown';
      throw Exception('Checkout failed (status $status): $error');
    }
    return Uri.parse(url);
  }

  Future<bool> openCheckout(Uri url) async {
    return launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
