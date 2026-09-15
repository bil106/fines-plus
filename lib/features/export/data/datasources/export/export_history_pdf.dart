// ignore_for_file: depend_on_referenced_packages

import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/features/analytics/data/models/car_history_model.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportHistoryPdf {
  Future<Uint8List> generateBytes(String carNumber, List<CarHistory> history) async {
    final pdf = pw.Document();
    final font = await _loadFont();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("${S.current.car_history} $carNumber", style: pw.TextStyle(font: font, fontSize: 18)),
            pw.SizedBox(height: 12),
            ..._buildHistorySections(font, history),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  /// A branded report meant to be handed to a car buyer: the app logo, the
  /// current mileage, the full maintenance history, and every fine that's
  /// ever been checked for this car (with paid/unpaid status) — the single
  /// artifact this feature is actually for someone who doesn't use the app
  /// to see and recognize the app's name.
  Future<Uint8List> generateBuyerReportBytes({
    required String carNumber,
    required List<CarHistory> history,
    required List<FineHistory> finesHistory,
  }) async {
    final pdf = pw.Document();
    final font = await _loadFont();
    final logoBytes = await rootBundle.load('assets/logo/fines_logo.png');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    final mileage = history.fold<int>(0, (max, h) => h.mileage > max ? h.mileage : max);
    final fines = _dedupeFines(finesHistory);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Image(logo, width: 36, height: 36),
              pw.SizedBox(width: 10),
              pw.Text('Fines+', style: pw.TextStyle(font: font, fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Spacer(),
              pw.Text(
                DateFormat('dd.MM.yyyy').format(DateTime.now()),
                style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            "${S.current.buyer_report} $carNumber",
            style: pw.TextStyle(font: font, fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            "${S.current.current_mileage}: $mileage ${S.current.km}",
            style: pw.TextStyle(font: font, fontSize: 13),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            S.current.car_history,
            style: pw.TextStyle(font: font, fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          ..._buildHistorySections(font, history),
          pw.SizedBox(height: 16),
          pw.Text(
            S.current.fines,
            style: pw.TextStyle(font: font, fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (fines.isEmpty)
            pw.Text(S.current.no_fines, style: pw.TextStyle(font: font, fontSize: 12))
          else
            pw.Table.fromTextArray(
              headers: [S.current.date, S.current.description, S.current.price, S.current.status],
              data: fines
                  .map((f) => [f.date, f.description, f.amount, f.isPaid ? S.current.paid : S.current.not_paid])
                  .toList(),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(4),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              cellStyle: pw.TextStyle(font: font, fontSize: 10),
              headerStyle: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
        ],
      ),
    );

    return pdf.save();
  }

  Future<pw.Font> _loadFont() async {
    final ttf = await rootBundle.load('assets/fonts/Fines/Roboto-Regular.ttf');
    return pw.Font.ttf(ttf);
  }

  List<pw.Widget> _buildHistorySections(pw.Font font, List<CarHistory> history) {
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

    return [
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
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(1),
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
    ];
  }

  /// The same fine can show up in multiple saved checks (e.g. checked again
  /// a month later); collapse by fine id and treat it as paid if any of the
  /// saved checks recorded it as paid.
  List<_ReportFine> _dedupeFines(List<FineHistory> finesHistory) {
    final byId = <String, _ReportFine>{};
    for (final check in finesHistory) {
      for (var i = 0; i < check.fines.length; i++) {
        final fine = check.fines[i];
        final id = fine['id']?.toString() ?? '${check.id}_$i';
        final isPaid = check.paidFines.contains(id) || (byId[id]?.isPaid ?? false);
        byId[id] = _ReportFine(
          date: (fine['date'] ?? fine['violationDate'] ?? fine['datetime'] ?? '').toString(),
          description: (fine['description'] ?? fine['article'] ?? fine['offense'] ?? '').toString(),
          amount: (fine['amount'] ?? fine['suma'] ?? fine['penalty'] ?? '').toString(),
          isPaid: isPaid,
        );
      }
    }
    return byId.values.toList();
  }
}

class _ReportFine {
  final String date;
  final String description;
  final String amount;
  final bool isPaid;
  _ReportFine({required this.date, required this.description, required this.amount, required this.isPaid});
}
