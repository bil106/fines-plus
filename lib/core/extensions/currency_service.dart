import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyService {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  Map<String, double>? _rates;
  Future<void>? _initFuture;

  /// Loads the rates once; later calls reuse the same load.
  Future<void> init() => _initFuture ??= _init();

  /// Completes once [init] has finished (with live or fallback rates), so a
  /// total computed after it uses real rates. Completes at once if [init]
  /// was never called.
  Future<void> get ready => _initFuture ?? Future.value();

  /// [amount] in the app's base currency (UAH). Every total is summed in
  /// UAH and converted to the display currency afterwards, so a record's
  /// cost - stored in whatever currency it was entered in - has to be
  /// brought to UAH first. A record without a currency is already UAH.
  double toUah(double amount, String? currency) =>
      (currency == null || currency.isEmpty) ? amount : convert(amount, 'UAH', fromCurrency: currency);

  Future<void> _init() async {
    try {
      await _fetchRates();
    } catch (e) {
      debugPrint("CurrencyService init error: $e");

      _rates = {
        "UAH": 1.0,
        "USD": 0.024, 
        "EUR": 0.022, 
      };
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
  Future<void> setCurrency(String newCurrency) async {
   
    if (_rates == null) {
      await init();
    }


  }

}
