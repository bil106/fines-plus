import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyService {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal() {
    init();
  }

  final _currencyStreamController = StreamController<Map<String, double>?>.broadcast();
  Map<String, double>? _rates;

  Stream<Map<String, double>?> get currencyStream => _currencyStreamController.stream;

  Future<void> init() async {
    try {
      await _fetchRates();
      _currencyStreamController.add(_rates);
    } catch (e) {
      debugPrint("CurrencyService init error: $e");
      _rates = {"UAH": 1.0, "USD": 0.024, "EUR": 0.022};
      _currencyStreamController.add(_rates);
    }
  }

  Future<void> _fetchRates() async {
    final url = Uri.parse('https://open.er-api.com/v6/latest/UAH');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Currency API HTTP error: ${response.statusCode}");
    }

    final data = jsonDecode(response.body);
    if (data['rates'] == null) {
      throw Exception('Currency API returned null rates');
    }

    _rates = Map<String, double>.from(data['rates'].map((key, value) => MapEntry(key, (value as num).toDouble())));
    _rates!["UAH"] = 1.0;

    _currencyStreamController.add(_rates);
  }

  Future<void> refreshRates() async {
    await _fetchRates();
  }

  double convert(double amount, String toCurrency, {required String fromCurrency}) {
    if (_rates == null) return amount;
    if (fromCurrency == toCurrency) return amount;

    final fromRate = _rates![fromCurrency];
    final toRate = _rates![toCurrency];

    if (fromRate == null || toRate == null) return amount;

    final amountInUah = fromCurrency == "UAH" ? amount : amount / fromRate;
    final converted = toCurrency == "UAH" ? amountInUah : amountInUah * toRate;

    return converted;
  }

  void dispose() {
    _currencyStreamController.close();
  }
}
