import 'dart:convert';
import 'package:http/http.dart' as http;

class CarInfoRemoteDataSource {
  final String baseUrl;

  CarInfoRemoteDataSource({this.baseUrl = "http://localhost:3000/api"});

  Future<List<Map<String, dynamic>>> checkFines({
    required String carNumber,
    required String docSeries,
    required String docNumber,
    required String captchaToken,
  }) async {
    final url = Uri.parse('$baseUrl/fines');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "carNumber": carNumber,
        "docSeries": docSeries,
        "docNumber": docNumber,
        "captchaToken": captchaToken,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Error API: ${response.statusCode} ${response.body}");
    }

    final data = jsonDecode(response.body);

    if (data["fines"] is List) {
      return List<Map<String, dynamic>>.from(data["fines"]);
    } else if (data["fines"] is Map) {
      return [Map<String, dynamic>.from(data["fines"])];
    }
    return [];
  }
}
