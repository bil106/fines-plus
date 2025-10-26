import 'dart:io';

import 'package:flutter/foundation.dart';

void main() {
  final directory = Directory.current;
  final regex = RegExp(r'[А-Яа-яЁё]');

  directory.listSync(recursive: true).forEach((file) {
    if (file is File && file.path.endsWith('.dart')) {
      final lines = file.readAsLinesSync();

      for (int i = 0; i < lines.length; i++) {
        if (regex.hasMatch(lines[i])) {
          if (kDebugMode) {
            print('⚠️ Cyrillic found in file: ${file.path}, line ${i + 1}: ${lines[i]}');
          }
        }
      }
    }
  });
}


//dart check_cyrillic.dart