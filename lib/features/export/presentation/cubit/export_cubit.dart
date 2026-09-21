import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_data/core_data.dart';
import 'package:fines_plus/features/analytics/data/models/event_model.dart';
import 'package:fines_plus/features/export/data/datasources/export/export_history_csv.dart';
import 'package:fines_plus/features/export/data/datasources/export/export_history_pdf.dart';
import 'package:fines_plus/features/export/data/repository/export_repository.dart';
import 'package:fines_plus/features/history/domain/history_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExportCubit extends Cubit<void> {
  final ExportRepositoryImpl exportRepository;
  final ExportHistoryPdf exportPdf;
  final ExportHistoryCsv exportCsv;

  ExportCubit({required this.exportRepository, required this.exportPdf, required this.exportCsv}) : super(null);

  Future<File> exportPdfFile(String carNumber, List<EventModel> history) async {
    final carHistoryList = exportRepository.convertEventsToCarHistory(history);
    final pdfBytes = await exportPdf.generateBytes(carNumber, carHistoryList);
    final dir = await getTemporaryDirectory();
    final safeCarNumber = carNumber.isEmpty ? "car" : carNumber;
    final file = File('${dir.path}/$safeCarNumber-history.pdf');
    return file.writeAsBytes(pdfBytes);
  }

Future<File> exportCsvFile(String carNumber, List<EventModel> history) async {
    final carHistoryList = exportRepository.convertEventsToCarHistory(history);
    final csvBytes = await exportCsv.generateBytes(carNumber, carHistoryList);
    final dir = await getTemporaryDirectory();

    final safeCarNumber = carNumber.isEmpty ? "car" : carNumber;

    final file = File('${dir.path}/$safeCarNumber-history.csv');
    return file.writeAsBytes(csvBytes);
  }

  Future<File> exportBuyerReportFile(
    String carNumber,
    List<EventModel> history, {
    required String brandName,
    required String logoAssetPath,
  }) async {
    final carHistoryList = exportRepository.convertEventsToCarHistory(history);

    List<FineHistory> finesHistory = [];
    try {
      // Anonymous/trial users (or anyone Firestore rejects) simply get a
      // report with an empty fines section instead of failing the export.
      finesHistory = await HistoryRepository(FirebaseFirestore.instance).getHistory(carNumber).first;
    } catch (_) {}

    final pdfBytes = await exportPdf.generateBuyerReportBytes(
      carNumber: carNumber,
      history: carHistoryList,
      finesHistory: finesHistory,
      brandName: brandName,
      logoAssetPath: logoAssetPath,
    );
    final dir = await getTemporaryDirectory();
    final safeCarNumber = carNumber.isEmpty ? "car" : carNumber;
    final file = File('${dir.path}/$safeCarNumber-buyer-report.pdf');
    return file.writeAsBytes(pdfBytes);
  }
}
