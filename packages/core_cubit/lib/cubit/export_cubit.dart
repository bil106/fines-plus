import 'package:core_data/core_data.dart';
import 'package:core_repository/export_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ExportCubit extends Cubit<void> {
  final ExportHistoryPdf exportPdf;
  final ExportHistoryCsv exportCsv;

  ExportCubit({required this.exportPdf, required this.exportCsv}) : super(null);

  Future<void> exportAsPdf(String carNumber, List<CarHistory> history) async {
    await exportPdf(carNumber, history);
  }

  Future<void> exportAsCsv(String carNumber, List<CarHistory> history) async {
    await exportCsv(carNumber, history);
  }
}
