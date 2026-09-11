// ignore_for_file: depend_on_referenced_packages

import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/features/analytics/data/models/car_history_model.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportHistoryPdf {
  Future<Uint8List> generateBytes(String carNumber, List<CarHistory> history) async {
    final pdf = pw.Document();
    final ttf = await rootBundle.load('assets/fonts/Fines/Roboto-Regular.ttf');
    final font = pw.Font.ttf(ttf);

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
        DateTime parsed;

        try {
          parsed = DateTime.parse(h.date);
        } catch (_) {
          parsed = DateFormat('dd.MM.yyyy').parse(h.date);
        }
        final monthKey = DateFormat.yMMMM('uk').format(DateTime(parsed.year, parsed.month));
        groupedByMonth.putIfAbsent(monthKey, () => []).add(h);
      } else {
        groupedByMonth.putIfAbsent(h.date, () => []).add(h);
      }
    }

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("${S.current.car_history} $carNumber", style: pw.TextStyle(font: font, fontSize: 18)),
            pw.SizedBox(height: 12),
            for (var entry in groupedByMonth.entries) ...[
              pw.Text(
                entry.key,
                style: pw.TextStyle(font: font, fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 6),
              pw.Table.fromTextArray(
                headers: [S.current.type, S.current.date, S.current.mileage, S.current.price],
                data: [
                  ...entry.value.map((h) => [h.type, h.date, h.mileage.toString(), h.cost.toStringAsFixed(0)]),
                  [
                    "",
                    "",
                    S.current.amount_month,
                    entry.value.fold<double>(0, (sum, h) => sum + h.cost).toStringAsFixed(0),
                  ],
                ],
                columnWidths: {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(2),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(1),
                },
                cellStyle: pw.TextStyle(font: font),
                headerStyle: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),
            ],
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  "${S.current.total}: ${totalCost.toStringAsFixed(0)}",
                  style: pw.TextStyle(font: font, fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }
}
