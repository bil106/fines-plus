import 'dart:convert';

import 'package:core_data/core_data.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FinesBackendDataSource {
  final http.Client client;

  FinesBackendDataSource(this.client);

  String get _baseUrl => 'http://127.0.0.1:3000';

  Future<bool> _isServerAvailable() async {
    try {
      final response = await client.get(Uri.parse('$_baseUrl/')).timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> _waitForServer({int retries = 5}) async {
    for (int i = 0; i < retries; i++) {
      if (await _isServerAvailable()) return;
      await Future.delayed(const Duration(seconds: 1));
    }
    throw Exception('Server unavailable after $retries attempts');
  }

  Future<List<Fine>> getFines({
    required String carNumber,
    required String docSeries,
    required String docNumber,
  }) async {
    debugPrint('🔹 Request for fines: carNumber=$carNumber, docSeries=$docSeries, docNumber=$docNumber');

    await _waitForServer();

    final url = Uri.parse('$_baseUrl/api/fines');
    final response = await client.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "carNumber": carNumber,
        "docSeries": docSeries,
        "docNumber": docNumber,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['fines'] as List).map((e) => Fine.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch fines: ${response.statusCode}');
    }
  }
}
