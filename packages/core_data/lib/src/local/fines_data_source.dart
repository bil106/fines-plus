import 'package:core_data/core_data.dart';

abstract class FinesDataSource {
  Future<List<Fine>> getFines({
    required String carNumber,
    required String docSeries,
    required String docNumber,
  });
}

