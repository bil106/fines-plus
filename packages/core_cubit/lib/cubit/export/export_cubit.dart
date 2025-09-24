import 'dart:io';
import 'package:core_repository/export/export_history_csv.dart';
import 'package:core_repository/export/export_history_pdf.dart';
import 'package:path_provider/path_provider.dart';


import 'package:core_data/core_data.dart';
import 'package:core_repository/export_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ExportCubit extends Cubit<void> {
  final ExportRepositoryImpl exportRepository;
  final ExportHistoryPdf exportPdf;
  final ExportHistoryCsv exportCsv;

  ExportCubit({
    required this.exportRepository,
    required this.exportPdf,
    required this.exportCsv,
  }) : super(null);

  Future<File> exportPdfFile(String carNumber, List<EventModel> history) async {
    final carHistoryList = exportRepository.convertEventsToCarHistory(history);
    final pdfBytes = await exportPdf.generateBytes(carNumber, carHistoryList);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$carNumber-history.pdf');
    return file.writeAsBytes(pdfBytes);
  }

  Future<File> exportCsvFile(String carNumber, List<EventModel> history) async {
    final carHistoryList = exportRepository.convertEventsToCarHistory(history);
    final csvBytes = await exportCsv.generateBytes(carNumber, carHistoryList);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$carNumber-history.csv');
    return file.writeAsBytes(csvBytes);
  }
}
