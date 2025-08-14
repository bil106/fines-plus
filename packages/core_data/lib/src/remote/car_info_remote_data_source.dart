import 'dart:convert';
import 'package:http/http.dart' as http;

class CarInfoRemoteDataSource {
  final String apiKey;
  final String baseUrl;

  CarInfoRemoteDataSource({
    required this.apiKey,
    this.baseUrl = 'https://opendatabot.com/api/v3',
  });

  Future<Map<String, dynamic>> checkFines({
    required String carNumber,
    required String techPassport,
  }) async {
    final url = Uri.parse('$baseUrl/fines');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'car_number': carNumber,
        'tech_passport': techPassport,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка API: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> checkInsurance({
    required String carNumber,
  }) async {
    final url = Uri.parse('$baseUrl/insurance');
    final response = await http.get(
      url.replace(queryParameters: {'car_number': carNumber}),
      headers: {'Authorization': 'Bearer $apiKey'},
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка API: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body);
  }
}
