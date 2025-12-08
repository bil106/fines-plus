// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:typed_data';
import 'package:core_localization/generated/l10n.dart';
import 'package:csv/csv.dart';
import 'package:fines_plus/features/analytics/data/models/car_history_model.dart';
import 'package:intl/intl.dart';

class ExportHistoryCsv {
  Future<Uint8List> generateBytes(String carNumber, List<CarHistory> history) async {
    final totalCost = history.fold<double>(0, (sum, h) => sum + h.cost);

    final Map<String, List<CarHistory>> groupedByMonth = {};
    for (var h in history) {
      List<String> parts;
      if (h.date.contains('.')) {
        parts = h.date.split('.').reversed.toList();
      } else {
        parts = h.date.split('-');
      }

      if (parts.length >= 2) {
        final year = int.tryParse(parts[0]) ?? 0;
        final month = int.tryParse(parts[1]) ?? 1;
        final date = DateTime(year, month, 1);
        final monthKey = DateFormat.yMMMM('uk').format(date);
        groupedByMonth.putIfAbsent(monthKey, () => []).add(h);
      } else {
        groupedByMonth.putIfAbsent(h.date, () => []).add(h);
      }
    }

    final List<List<dynamic>> rows = [];
    rows.add([S.current.type, S.current.date, S.current.mileage, S.current.price]);

    groupedByMonth.forEach((month, list) {
      rows.add([month, '', '', '']);
      rows.addAll(list.map((h) => [h.type, h.date, h.mileage, h.cost.toStringAsFixed(0)]));
      final monthTotal = list.fold<double>(0, (sum, h) => sum + h.cost);
      rows.add(['', '', S.current.amount_month, monthTotal.toStringAsFixed(0)]);
    });

    rows.add(['', '', S.current.total, totalCost.toStringAsFixed(0)]);

    final csvString = const ListToCsvConverter(fieldDelimiter: ';').convert(rows);

    final bytes = utf8.encode(csvString);
    final bom = [0xEF, 0xBB, 0xBF];
    return Uint8List.fromList([...bom, ...bytes]);
  }
}
