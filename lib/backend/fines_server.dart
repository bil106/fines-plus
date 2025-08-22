import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

class FinesServer {
  HttpServer? _server;

  Future<void> start() async {
    if (_server != null) return;

    final router = Router();

    
    router.get('/', (Request req) {
      return Response.ok('✅ Server is running');
    });

  
    router.post('/api/fines', (Request req) async {
      final body = await req.readAsString();
      final data = jsonDecode(body);

      final carNumber = data['carNumber'];
      final docSeries = data['docSeries'];
      final docNumber = data['docNumber'];

      if (kDebugMode) {
        print('🔹 Запрос штрафов: $carNumber, $docSeries, $docNumber');
      }

      final fines = [
         {"id": "1", "carNumber": carNumber, "amount": 500, "description": "Превышение скорости"},
        // {"id": "2", "carNumber": carNumber, "amount": 300, "description": "Неправильная парковка"},
      ];

      return Response.ok(jsonEncode({"fines": fines}), headers: {'Content-Type': 'application/json'});
    });

  
    final handler = const Pipeline().addMiddleware(logRequests()).addHandler(router.call);

    _server = await io.serve(handler, InternetAddress.loopbackIPv4, 3000);
    if (kDebugMode) {
      print('🚀 FinesServer запущен на http://${_server!.address.host}:${_server!.port}');
    }
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }
}
