import 'dart:convert';
import 'package:http/http.dart' as http;

class FinesApi {
  static const String baseUrl = 'https://my-fines-service-201100655892.europe-west1.run.app';

  Future<List<Map<String, dynamic>>> fetchFines({
    required String carNumber,
    required String docSeries,
    required String docNumber,
    required String captchaToken,
    required String cookies,
  }) async {
    final url = Uri.parse('$baseUrl/api/fines');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'carNumber': carNumber,
        'docSeries': docSeries,
        'docNumber': docNumber,
        'captchaToken': captchaToken,
        'cookies': cookies,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['fines'] ?? []);
    } else {
      throw Exception('Server exception: ${response.statusCode}');
    }
  }
}
