// ignore_for_file: file_names, depend_on_referenced_packages

import 'dart:io';

import 'package:core_localization/generated/l10n.dart';
import 'package:csv/csv.dart';
import 'package:fines_plus/features/analytics/data/models/car_history_model.dart';
import 'package:fines_plus/features/analytics/data/models/event_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

abstract class ExportRepository {
  Future<void> exportToPdf(String carNumber, List<CarHistory> history);
  Future<void> exportToCsv(String carNumber, List<CarHistory> history);
}

class ExportRepositoryImpl implements ExportRepository {
  List<CarHistory> convertEventsToCarHistory(List<EventModel> events) {
    return events.map((e) {
      final mileageValue = int.tryParse(
            e.mileage.replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0;

      final costValue = e.amount;

      String typeDetail;
      if (e.category.name == "fuel") {
        typeDetail = "${S.current.fuel} - ${e.title}";
      } else if (e.category.name == "service") {
        typeDetail = "${S.current.service}- ${e.title}";
      } else {
        typeDetail = e.title;
      }

    return CarHistory(
        type: typeDetail,
        date: DateFormat('yyyy-MM-dd').format(e.date),
        mileage: mileageValue,
        cost: costValue.roundToDouble(),
      );

    }).toList();
  }

  @override
  Future<void> exportToPdf(String carNumber, List<CarHistory> history) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Text("${S.current.car_history} $carNumber"),
            pw.Table.fromTextArray(
              headers: [S.current.type, S.current.date, S.current.mileage, S.current.price],
              data: history
                  .map((h) => [
                        h.type,
                        h.date,
                        h.mileage.toString(),
                        h.cost.toStringAsFixed(0),
                      ])
                  .toList(),
            ),
          ],
        ),
      ),
    );

    final file = File("history_$carNumber.pdf");
    await file.writeAsBytes(await pdf.save());
  }

  @override
  Future<void> exportToCsv(String carNumber, List<CarHistory> history) async {
    final rows = [
      [S.current.type, S.current.date, S.current.mileage, S.current.price],
      ...history.map((h) => [
            h.type,
            h.date,
            h.mileage,
            h.cost.toStringAsFixed(0),
          ]),
    ];
    final csv = const ListToCsvConverter().convert(rows);

    final file = File("history_$carNumber.csv");
    await file.writeAsString(csv);
  }
}



