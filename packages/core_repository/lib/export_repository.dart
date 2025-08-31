// ignore_for_file: file_names

import 'dart:io';

import 'package:core_data/core_data.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;

abstract class ExportRepository {
  Future<void> exportToPdf(String carNumber, List<CarHistory> history);
  Future<void> exportToCsv(String carNumber, List<CarHistory> history);
}
class ExportRepositoryImpl implements ExportRepository {
  @override
  Future<void> exportToPdf(String carNumber, List<CarHistory> history) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Text("Історія авто $carNumber"),
            pw.Table.fromTextArray(
              headers: ["Тип", "Дата", "Пробіг", "Ціна"],
              data: history.map((h) => [h.type, h.date, h.mileage, h.cost]).toList(),
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
      ["Тип", "Дата", "Пробіг", "Ціна"],
      ...history.map((h) => [h.type, h.date, h.mileage, h.cost]),
    ];
    final csv = const ListToCsvConverter().convert(rows);

    final file = File("history_$carNumber.csv");
    await file.writeAsString(csv);
  }
}
class ExportHistoryPdf {
  final ExportRepository repository;
  ExportHistoryPdf(this.repository);

  Future<void> call(String carNumber, List<CarHistory> history) {
    return repository.exportToPdf(carNumber, history);
  }
}

class ExportHistoryCsv {
  final ExportRepository repository;
  ExportHistoryCsv(this.repository);

  Future<void> call(String carNumber, List<CarHistory> history) {
    return repository.exportToCsv(carNumber, history);
  }
}
