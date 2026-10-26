import 'package:fines_plus/features/maintenance/domain/insurance_policy_page_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Loads the policy-check page behind an OSCPV policy's QR code.
class InsurancePolicyLookup {
  static const _hostSuffixes = ['.eua.in.ua', '.mtsbu.ua'];
  static const _timeout = Duration(seconds: 10);

  /// Only the registry's own pages are fetched - a QR code is untrusted
  /// input and must not make the app request arbitrary addresses.
  static bool isPolicyUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || uri.scheme != 'https') return false;
    return _hostSuffixes.any(uri.host.endsWith);
  }

  /// Null when [qrValue] isn't a policy link, the page can't be loaded, or
  /// it isn't the expected policy page.
  Future<InsurancePolicyInfo?> fetch(String qrValue) async {
    if (!isPolicyUrl(qrValue)) return null;
    try {
      final response = await http
          .get(Uri.parse(qrValue.trim()), headers: {'Accept-Language': 'uk'})
          .timeout(_timeout);
      if (response.statusCode != 200) return null;
      return InsurancePolicyPageParser.parse(response.body);
    } catch (e) {
      debugPrint('Insurance policy lookup failed: $e');
      return null;
    }
  }
}
