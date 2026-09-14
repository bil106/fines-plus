import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class CarInfoRemoteDataSource {
  final String baseUrl;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  CarInfoRemoteDataSource(
    this.firestore,
    this.auth, {
    this.baseUrl = "https://my-fines-service-201100655892.europe-west1.run.app",
  });

  Future<List<Map<String, dynamic>>> checkFines({
    required String carNumber,
    required String docSeries,
    required String docNumber,
    required String captchaToken,
  }) async {
    final url = Uri.parse('$baseUrl/api/fines');

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
