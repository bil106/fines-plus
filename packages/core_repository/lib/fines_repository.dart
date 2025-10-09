import 'package:core_data/core_data.dart';

abstract class FinesRepository {
  Future<List<Fine>> fetchFines({
    required String carNumber,
    required String docSeries,
    required String docNumber,
  });
}

  


