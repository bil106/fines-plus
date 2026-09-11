
import 'package:fines_plus/features/export/data/datasources/export/export_history_csv.dart';
import 'package:fines_plus/features/export/data/datasources/export/export_history_pdf.dart';
import 'package:fines_plus/features/export/data/repository/export_repository.dart';

import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<ExportRepository>(() => ExportRepositoryImpl());

  getIt.registerLazySingleton<ExportRepositoryImpl>(() => ExportRepositoryImpl());

  getIt.registerFactory(() => ExportHistoryPdf());
  getIt.registerFactory(() => ExportHistoryCsv());
}
