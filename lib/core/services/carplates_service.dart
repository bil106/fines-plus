import 'dart:convert';
import 'package:http/http.dart' as http;

class CarPlatesService {
  static const _baseUrl = 'https://api.carplates.app/ua/gov-registration';
  static const _apiKey = 'DEMOdemoDEMOdemoDEMOdemoDEMOdemo';

  Future<Map<String, dynamic>> fetchCarInfo(String number) async {
    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {'X-Locale': 'uk', 'X-API-Key': _apiKey, 'Content-Type': 'application/json'},
          body: jsonEncode({'number': number}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        return json['data'] as Map<String, dynamic>;
      } else {
        throw Exception(json['error'] ?? 'Помилка запиту');
      }
    } else {
      throw Exception('Помилка з’єднання (${response.statusCode})');
    }
  }
}

