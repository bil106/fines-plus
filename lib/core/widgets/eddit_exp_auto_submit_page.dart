// ignore_for_file: unnecessary_brace_in_string_interps


import 'package:core/config/app_urls.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';


class EditExpAutoSubmitPage extends StatefulWidget {
  final int expId;
  final Map<String, String> fieldValues;

  const EditExpAutoSubmitPage({super.key, required this.expId, required this.fieldValues});

  @override
  State<EditExpAutoSubmitPage> createState() => _EditExpAutoSubmitPageState();
}

class _EditExpAutoSubmitPageState extends State<EditExpAutoSubmitPage> {
  bool _loading = true;
  String? _status;

  @override
  void initState() {
    super.initState();
    _publishComment();
  }

  Future<void> _publishComment() async {
    try {
      // 1️⃣ Authorization via Google
      final result = await FlutterWebAuth2.authenticate(url: AppUrls.google, callbackUrlScheme: 'myapp');

      final uri = Uri.parse(result);
      final cookies = uri.queryParameters; // get tokens/session
      debugPrint('Cookies: $cookies');

      // 2️⃣ We are publishing the post
      final response = await http.post(
        Uri.parse(AppUrls.addExp(widget.expId)),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Cookie': cookies.entries.map((e) => '${e.key}=${e.value}').join('; '),
        },
        body: {
          'comment': widget.fieldValues['comment'] ?? '',
          'offRoad': widget.fieldValues['offRoadAccidents'] == 'true' ? 'on' : '',
          'invisible': widget.fieldValues['invisibleEvent'] == 'true' ? 'on' : '',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
          _status = 'Comment published';
        });
      } else {
        setState(() {
          _loading = false;
          _status = 'Error: ${response.statusCode}\n${response.body}';
        });
      }
    } catch (e, st) {
      debugPrint('Auth/Publish error: $e\n$st');
      setState(() {
        _loading = false;
        _status = 'Authorization/publication error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posting a comment')),
      body: Center(child: _loading ? const CircularProgressIndicator() : Text(_status ?? 'Unknown result')),
    );
  }
}
