import 'package:core_repository/export_repository.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<ExportRepository>(() => ExportRepositoryImpl());

  getIt.registerLazySingleton<ExportRepositoryImpl>(() => ExportRepositoryImpl());

  getIt.registerFactory(() => ExportHistoryPdf());
  getIt.registerFactory(() => ExportHistoryCsv());
}
