// ignore_for_file: depend_on_referenced_packages

import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_utils/formatters/plate_market.dart';
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
  /// current mileage, the full maintenance history, and the fines still
  /// unpaid on this car (or a "no fines" line; the whole fines section is
  /// omitted when [includeFines] is false) — the single
  /// artifact this feature is actually for someone who doesn't use the app
  /// to see and recognize the app's name.
  Future<Uint8List> generateBuyerReportBytes({
    required String carNumber,
    required String carMake,
    required List<CarHistory> history,
    required List<FineHistory> finesHistory,
    required String brandName,
    required String logoAssetPath,
    required bool includeFines,
    required PlateMarket plateMarket,
  }) async {
    final pdf = pw.Document();
    final font = await _loadFont();
    final logoBytes = await rootBundle.load(logoAssetPath);
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    final mileage = history.fold<int>(0, (max, h) => h.mileage > max ? h.mileage : max);
    final fines = _unpaidFines(finesHistory);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Image(logo, width: 36, height: 36),
              pw.SizedBox(width: 10),
              pw.Text(brandName, style: pw.TextStyle(font: font, fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Spacer(),
              pw.Text(
                DateFormat('dd.MM.yyyy').format(DateTime.now()),
                style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            S.current.buyer_report,
            style: pw.TextStyle(font: font, fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                S.current.car_history,
                style: pw.TextStyle(font: font, fontSize: 15, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(width: 16),
              pw.Spacer(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  if (carNumber.isNotEmpty) ...[
                    _buildPlate(font, carNumber, plateMarket),
                    pw.SizedBox(height: 6),
                  ],
                  pw.Text(
                    [
                      if (carMake.isNotEmpty) carMake,
                      "${S.current.current_mileage}: $mileage ${S.current.km}",
                    ].join(' • '),
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          ..._buildHistorySections(font, history),
          if (includeFines) ...[
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
                headers: [S.current.date, S.current.description, S.current.price],
                data: fines.map((f) => [f.date, f.description, f.amount]).toList(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(5),
                  2: const pw.FlexColumnWidth(2),
                },
                cellStyle: pw.TextStyle(font: font, fontSize: 10),
                headerStyle: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold, fontSize: 10),
              ),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  /// The plate in the brand market's style (see LicensePlateBadge): a blue
  /// "UA" / EU strip on the left for UA / ES, a "USA" / "MÉXICO" header above
  /// the number for US / MX, the blue Mercosur band on top for AR.
  pw.Widget _buildPlate(pw.Font font, String carNumber, PlateMarket market) {
    final number = pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: pw.Text(
        market.display(carNumber),
        style: pw.TextStyle(font: font, fontSize: 30, fontWeight: pw.FontWeight.bold),
      ),
    );

    final field = switch (market) {
      PlateMarket.ua => pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          _plateStrip(
            font,
            'UA',
            PdfColors.blue800,
            pw.Column(
              children: [
                pw.Container(width: 16, height: 5, color: PdfColors.blue400),
                pw.Container(width: 16, height: 5, color: PdfColors.yellow),
              ],
            ),
          ),
          number,
        ],
      ),
      PlateMarket.es => pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          _plateStrip(
            font,
            'E',
            PdfColors.indigo900,
            pw.Container(
              width: 14,
              height: 14,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                border: pw.Border.all(color: PdfColors.yellow, width: 1.5),
              ),
            ),
          ),
          number,
        ],
      ),
      PlateMarket.us || PlateMarket.mx => pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text(
              market == PlateMarket.us ? 'USA' : 'MÉXICO',
              style: pw.TextStyle(font: font, fontSize: 9, letterSpacing: 2.4, color: PdfColors.blueGrey900),
            ),
          ),
          number,
        ],
      ),
      PlateMarket.ar => pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            decoration: const pw.BoxDecoration(
              color: PdfColors.blue800,
              borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(4)),
            ),
            child: pw.Text(
              'REPÚBLICA ARGENTINA',
              style: pw.TextStyle(font: font, fontSize: 7, letterSpacing: 0.8, color: PdfColors.white),
            ),
          ),
          number,
        ],
      ),
    };

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.black, width: 2),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: field,
    );
  }

  /// The blue strip on the left of UA / EU plates: an emblem on top, the
  /// country code at the bottom.
  pw.Widget _plateStrip(pw.Font font, String code, PdfColor color, pw.Widget emblem) {
    return pw.Container(
      width: 26,
      height: 40,
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.horizontal(left: pw.Radius.circular(4)),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          emblem,
          pw.Text(code, style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.white)),
        ],
      ),
    );
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

  /// Fines currently outstanding on the car - a buyer only cares about what
  /// is still unpaid. Same rule as the fines screen: the latest check is the
  /// current state (getHistory() orders checks newest first); anything that
  /// dropped out of it is settled.
  List<_ReportFine> _unpaidFines(List<FineHistory> finesHistory) {
    if (finesHistory.isEmpty) return [];
    final latest = finesHistory.first;
    return [
      for (final entry in latest.fines.asMap().entries)
        if (!latest.isFinePaid(entry.value['id']?.toString() ?? '${entry.key}', entry.value))
          _ReportFine(
            date: (entry.value['date'] ?? entry.value['violationDate'] ?? entry.value['datetime'] ?? '').toString(),
            description: (entry.value['description'] ?? entry.value['article'] ?? entry.value['offense'] ?? '')
                .toString(),
            amount: (entry.value['amount'] ?? entry.value['suma'] ?? entry.value['penalty'] ?? '').toString(),
          ),
    ];
  }
}

class _ReportFine {
  final String date;
  final String description;
  final String amount;
  _ReportFine({required this.date, required this.description, required this.amount});
}
