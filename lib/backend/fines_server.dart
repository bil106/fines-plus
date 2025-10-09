import 'dart:convert';
import 'dart:io';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:flutter/foundation.dart';

class FinesServer {
  HttpServer? _server;

  Future<void> start() async {
    if (_server != null) return;

    final router = Router();

    router.get('/', (Request req) => Response.ok('Server is running'));

    router.post('/api/fines', (Request req) async {
      try {
        final body = await req.readAsString();
        final data = jsonDecode(body);

        String carNumber = (data['carNumber'] ?? '').toString();
        String docSeries = (data['docSeries'] ?? '').toString();
        String docNumber = (data['docNumber'] ?? '').toString();
        String captchaToken = (data['captchaToken'] ?? 'default-token').toString();
        String cookies = (data['cookies'] ?? '').toString();

        if (docSeries.length > 3 && docNumber.isEmpty) {
          docNumber = docSeries.substring(3);
          docSeries = docSeries.substring(0, 3);
        }

        if (kDebugMode) {
          print('🔹 Request: carNumber=$carNumber, docSeries=$docSeries, docNumber=$docNumber');
        }

        final html = await fetchFines(
          plate: carNumber,
          document: "$docSeries$docNumber",
          captchaToken: captchaToken,
          cookies: cookies,
        );

        final fines = parseFinesHtml(html);

        return Response.ok(jsonEncode({"fines": fines}), headers: {'Content-Type': 'application/json'});
      } catch (e, stack) {
        if (kDebugMode) {
          print("Error: $e");
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
      print('🚀 FinesServer running on http://${_server!.address.host}:${_server!.port}');
    }
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
  final searchUrl = Uri.parse("https://bdr.mvs.gov.ua/main/search/");

  final postResponse = await http.post(
    searchUrl,
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Origin": "https://bdr.mvs.gov.ua",
      "Referer": "https://bdr.mvs.gov.ua/",
      "User-Agent": "Mozilla/5.0",
      "Cookie": cookies,
      "Accept": "*/*",
    },
    body: {"plate": plate, "document": document, "g-recaptcha-response": captchaToken},
  );

  if (kDebugMode) print("🔹 POST Status: ${postResponse.statusCode}");

  String subUrl = postResponse.headers['location'] ?? '';
  if (!subUrl.startsWith('http') && subUrl.isNotEmpty) {
    subUrl = "https://bdr.mvs.gov.ua$subUrl";
  }

  if (kDebugMode) print("🔹 Redirecting to: $subUrl");

  final getResponse = await http.get(
    Uri.parse(subUrl),
    headers: {"User-Agent": "Mozilla/5.0", "Cookie": cookies, "Referer": searchUrl.toString()},
  );

  if (getResponse.statusCode != 200) {
    throw Exception("Error retrieving results page: ${getResponse.statusCode}");
  }

  return getResponse.body;
}

List<Map<String, dynamic>> parseFinesHtml(String html) {
  if (html.isEmpty) return [];

  final document = parse(html);


  final rows = document.querySelectorAll('table.fines-table tbody tr');

  List<Map<String, dynamic>> fines = [];

  for (final row in rows) {
    final cells = row.querySelectorAll('td');
    if (cells.length >= 3) {
      fines.add({
        "id": '',
        "violation": cells[1].text.trim(),
        "total": int.tryParse(cells[2].text.replaceAll(RegExp(r'\D'), '')) ?? 0,
        "date": cells[0].text.trim(),
      });
    }
  }

  return fines;
}
