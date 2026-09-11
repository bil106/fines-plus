import 'package:core_data/core_data.dart';
import 'package:core_repository/fines_repository.dart';

class FinesRepositoryImpl implements FinesRepository {
  final FinesBackendDataSource dataSource;

  FinesRepositoryImpl(this.dataSource);

  @override
  Future<List<Fine>> fetchFines({required String carNumber, required String docSeries, required String docNumber}) {
    return dataSource.getFines(carNumber: carNumber, docSeries: docSeries, docNumber: docNumber);
  }
}
