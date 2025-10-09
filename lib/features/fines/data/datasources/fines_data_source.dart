
// ignore_for_file: implementation_imports

import 'package:core_data/src/models/fine_model.dart';

abstract class FinesDataSource {
  Future<List<Fine>> getFines({
    required String carNumber,
    required String docSeries,
    required String docNumber,
  });
}

