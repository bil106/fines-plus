import 'package:core_data/core_data.dart';

abstract class FinesRepository {
  Future<List<Fine>> fetchFines({
    required String carNumber,
    required String docSeries,
    required String docNumber,
  });
}

// class FinesRepositoryImpl implements FinesRepository {
//   final FinesBackendDataSource dataSource;

//   FinesRepositoryImpl(this.dataSource);

//   @override
//   Future<List<Fine>> fetchFines({
//     required String carNumber,
//     required String docSeries,
//     required String docNumber,
//   }) {
//     return dataSource.getFines(
//       carNumber: carNumber,
//       docSeries: docSeries,
//       docNumber: docNumber,
//     );
//   }
  


