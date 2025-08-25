import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:html/parser.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'package:http/http.dart' as http;

class FinesServer {
  HttpServer? _server;

  Future<void> start() async {
    if (_server != null) return;

    final router = Router();

    router.get('/', (Request req) {
      return Response.ok('✅ Server is running');
    });

    router.post('/api/fines', (Request req) async {
      try {
        final body = await req.readAsString();
        final data = jsonDecode(body);

        String carNumber = (data['carNumber'] ?? '').toString();
        String docSeries = (data['docSeries'] ?? '').toString();
        String docNumber = (data['docNumber'] ?? '').toString();
        String captchaToken = (data['captchaToken'] ?? 'default-token').toString();
        String cookies = (data['cookies'] ?? '').toString();

        // Если docSeries длиннее 3 символов и docNumber пустой — разделяем
        if (docSeries.length > 3 && docNumber.isEmpty) {
          docNumber = docSeries.substring(3);
          docSeries = docSeries.substring(0, 3);
        }

        if (kDebugMode) {
          print('🔹 Запрос штрафов: carNumber=$carNumber, docSeries=$docSeries, docNumber=$docNumber');
        }

        final html = await fetchFines(
          plate: carNumber,
          document: "$docSeries$docNumber",
          captchaToken: captchaToken,
          cookies: cookies,
        );

        final fines = parseFinesHtml(html);

        // ✅ Важно: оборачиваем в объект с ключом "fines"
        final responseJson = jsonEncode({"fines": fines});

        return Response.ok(responseJson, headers: {'Content-Type': 'application/json'});
      } catch (e, stack) {
        if (kDebugMode) {
          print("❌ Ошибка при получении штрафов: $e");
          print(stack);
        }
        return Response.internalServerError(
          body: jsonEncode({"error": e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    final handler = const Pipeline().addMiddleware(logRequests()).addHandler(router.call);

    _server = await io.serve(handler, InternetAddress.loopbackIPv4, 3000);
    if (kDebugMode) {
      print('🚀 FinesServer запущен на http://${_server!.address.host}:${_server!.port}');
    }
  }
Future<bool> verifyCaptcha(String captchaToken) async {
    const secretKey = String.fromEnvironment('RECAPTCHA_SECRET_KEY');

    final response = await http.post(
      Uri.parse("https://www.google.com/recaptcha/api/siteverify"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"secret": secretKey, "response": captchaToken},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("🔎 Captcha verify response: $data");
      return data['success'] == true && (data['score'] ?? 0) > 0.5;
    }
    return false;
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }
}

Future<String> fetchFines({
  required String plate,
  required String document,
  required String captchaToken,
  required String cookies,
}) async {
  final url = Uri.parse("https://bdr.mvs.gov.ua/main/search/");

  if (kDebugMode) {
    print("🔹 Sending POST request to $url");
  }
  if (kDebugMode) {
    print("🔹 Body: plate=$plate, document=$document, captcha=$captchaToken");
  }
  if (kDebugMode) {
    print("🔹 Cookies: $cookies");
  }

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Origin": "https://bdr.mvs.gov.ua",
      "Referer": "https://bdr.mvs.gov.ua/",
      "User-Agent": "Mozilla/5.0",
      "Cookie": cookies,
    },
    body: {"plate": plate, "document": document, "g-recaptcha-response": captchaToken},
  );

  if (kDebugMode) {
    print("🔹 Status code: ${response.statusCode}");
  }
  if (kDebugMode) {
    print("🔹 Response headers: ${response.headers}");
  }
  if (kDebugMode) {
    print(
      "🔹 Response body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}",
    );
  }

  // If the site redirects (302), we try GET by Location
  if (response.statusCode == 302) {
    final redirectUrl = response.headers['location'];
    if (redirectUrl != null) {
      final redirectUri = redirectUrl.startsWith('http')
          ? Uri.parse(redirectUrl)
          : Uri.parse("https://bdr.mvs.gov.ua$redirectUrl");

      if (kDebugMode) {
        print("🔹 Following redirect to $redirectUri");
      }

      final res = await http.get(redirectUri, headers: {"Cookie": cookies, "User-Agent": "Mozilla/5.0"});

      if (kDebugMode) {
        print("🔹 Redirect GET status: ${res.statusCode}");
      }
      if (kDebugMode) {
        print(
          "🔹 Redirect body (first 500 chars): ${res.body.substring(0, res.body.length > 500 ? 500 : res.body.length)}",
        );
      }
      return res.body;
    }
  }

  // If 200, check for captcha
  if (response.statusCode == 200) {
    final body = response.body;
    if (body.contains("g-recaptcha")) {
      if (kDebugMode) {
        print("⚠️ Warning: captcha required or invalid");
      }
    } else {
      if (kDebugMode) {
        print("✅ Captcha seems passed (no g-recaptcha found)");
      }
    }
    return body;
  }

  throw Exception("Error: ${response.statusCode} ${response.body}");
}

List<Map<String, dynamic>> parseFinesHtml(String html) {
  if (html.isEmpty) return [];

  final document = parse(html);
  final items = document.querySelectorAll('div.item-list .item');
  List<Map<String, dynamic>> fines = [];

  for (var item in items) {
    final description = item.querySelector('.description')?.text.trim() ?? '';
    final amountText = item.querySelector('.amount')?.text.trim() ?? '0';
    final total = int.tryParse(amountText.replaceAll(RegExp(r'\D'), '')) ?? 0;
    final dateText = item.querySelector('.date')?.text.trim() ?? '';

    DateTime date;
    try {
      date = DateTime.parse(dateText);
    } catch (_) {
      date = DateTime.now();
    }

    fines.add({"id": '', "violation": description, "total": total, "date": date.toIso8601String()});
  }

  return fines;
}
